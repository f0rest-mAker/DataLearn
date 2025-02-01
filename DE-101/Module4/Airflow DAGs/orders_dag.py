import pandas as pd
import os
import glob
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.dummy import DummyOperator
from airflow.sensors.filesystem import FileSensor
from airflow.utils.dates import days_ago
from airflow.providers.postgres.operators.postgres import PostgresOperator

dir_path = os.path.dirname(os.path.realpath(__file__))

dag = DAG(
    "orders_DAG",
    start_date=days_ago(0, 0, 0, 0),
    template_searchpath=dir_path,
    catchup=False
)


def join_files():
    orders = pd.read_csv(dir_path+"/input/orders.csv")
    people = pd.read_csv(dir_path+"/input/people.csv")
    returns = pd.read_csv(dir_path+"/input/returns.csv")

    returns = returns.drop_duplicates(keep="last")
    orders = pd.merge(orders, people, on="region", how="inner")
    orders = pd.merge(orders, returns, on="order_id", how="left")
    orders = orders.fillna({"returned": "No"})

    orders.to_csv(dir_path+"/input/joined_data.csv")


def creating_dimension_csv():
    data = pd.read_csv(dir_path+"/input/joined_data.csv")
    data.drop(columns=["product_id"], axis=1, inplace=True)
    data.fillna("Null", inplace=True)

    ship = data[["ship_mode"]].drop_duplicates(keep="first")
    ship["ship_id"] = range(1, len(ship)+1)
    ship = ship[["ship_id", "ship_mode"]]
    product = data[["product_name", "category", "subcategory"]
                   ].drop_duplicates(keep="first")
    product["product_id"] = range(1, len(product)+1)
    product = product[["product_id",
                       "product_name", "category", "subcategory"]]
    customers = data[["customer_id", "customer_name",
                      "segment"]].drop_duplicates(keep="first")
    deliver = data[["country", "state", "city", "postal_code",
                    "region"]].drop_duplicates(keep="first")
    deliver["deliver_id"] = range(1, len(deliver)+1)
    deliver = deliver[["deliver_id", "country",
                       "state", "city", "postal_code", "region"]]

    order_details = pd.merge(data,
                             product,
                             on=["product_name", "category", "subcategory"],
                             how="inner")

    order_details = order_details[[
        "sales", "quantity", "profit", "discount", "order_id", "product_id"]]

    all_joined = pd.merge(data, ship, on=["ship_mode"])
    all_joined = pd.merge(all_joined, product, on=[
                          "product_name", "category", "subcategory"])
    all_joined = pd.merge(all_joined, deliver, on=[
                          "country", "state", "city", "postal_code", "region"])
    orders = all_joined[["order_id", "order_date", "ship_date",
                         "ship_id", "customer_id", "person", "returned", "deliver_id"]].drop_duplicates(subset=["order_id"], keep='first')
    
    ship.to_csv(dir_path+"/output/ship.csv", index=False)
    product.to_csv(dir_path+"/output/product.csv", index=False)
    customers.to_csv(dir_path+"/output/customer.csv", index=False)
    deliver.to_csv(dir_path+"/output/deliver.csv", index=False)
    order_details.to_csv(dir_path+"/output/order_details.csv", index=False)
    orders.to_csv(dir_path+"/output/orders.csv", index=False)


def create_sql_scripts():
    ship = pd.read_csv(dir_path+"/output/ship.csv")
    product = pd.read_csv(dir_path+"/output/product.csv")
    product["product_name"] = product["product_name"].str.replace("'", "\"")
    customers = pd.read_csv(dir_path+"/output/customer.csv")
    customers["customer_name"] = customers["customer_name"].str.replace("'", "\"")
    deliver = pd.read_csv(dir_path+"/output/deliver.csv")
    order_details = pd.read_csv(dir_path+"/output/order_details.csv")
    orders = pd.read_csv(dir_path+"/output/orders.csv")

    print("Dimensions and fact are highlighted")
    print("Creating INSERT SQL Scripts")

    with open(dir_path+"/output/insert_orders.sql", "w") as f:
        f.write("TRUNCATE TABLE dw.orders CASCADE;\n")
        for line in orders.to_numpy():
            f.write("INSERT INTO dw.orders VALUES (" +
                    f"'{line[0]}', '{line[1]}', '{line[2]}', '{line[5]}', '{line[6]}', {line[3]}, {line[7]}, '{line[4]}');\n")
    with open(dir_path+"/output/insert_ship.sql", "w") as f:
        f.write("TRUNCATE TABLE dw.ship_dim CASCADE;\n")
        for line in ship.to_numpy():
            f.write("INSERT INTO dw.ship_dim VALUES (" +
                    f"{line[0]}, '{line[1]}');\n")
    with open(dir_path+"/output/insert_product.sql", "w") as f:
        f.write("TRUNCATE TABLE dw.product_dim CASCADE;\n")
        for line in product.to_numpy():
            f.write("INSERT INTO dw.product_dim VALUES (" +
                    f"{line[0]}, '{line[1]}', '{line[2]}', '{line[3]}');\n")
    with open(dir_path+"/output/insert_deliver.sql", "w") as f:
        f.write("TRUNCATE TABLE dw.deliver_dim CASCADE;\n")
        for line in deliver.to_numpy():
            f.write("INSERT INTO dw.deliver_dim VALUES (" +
                    f"{line[0]}, '{line[1]}', '{line[2]}', '{line[3]}', {line[4]}, '{line[5]}');\n")
    with open(dir_path+"/output/insert_customers.sql", "w") as f:
        f.write("TRUNCATE TABLE dw.customer_dim CASCADE;\n")
        for line in customers.to_numpy():
            f.write("INSERT INTO dw.customer_dim VALUES (" +
                    f"'{line[0]}', '{line[1]}', '{line[2]}');\n")
    with open(dir_path+"/output/insert_order_details.sql", "w") as f:
        f.write("TRUNCATE TABLE dw.order_details CASCADE;\n")
        for line in order_details.to_numpy():
            f.write("INSERT INTO dw.order_details VALUES (" +
                    f"{line[0]}, {line[1]}, {line[2]}, {line[3]}, {line[5]}, '{line[4]}');\n")
    print("Scripts done")


def clean_after():
    print("Cleaning after...")
    print("Deleting csv files...", end=" ")
    os.remove(dir_path+"/input/orders.csv")
    os.remove(dir_path+"/input/joined_data.csv")
    for x in glob.glob(dir_path+"/output/*.csv"):
        os.remove(x)
    print("Done")
    print("Deleting scripts...", end=" ")
    for x in glob.glob(dir_path+"/output/insert*.sql"):
        os.remove(x)
    print("Done")


start = DummyOperator(
    dag=dag,
    task_id="start"
)

orders_sensor = FileSensor(
    task_id='wait_for_orders_file',
    filepath=dir_path+'/input/orders.csv'
)

people_sensor = FileSensor(
    dag=dag,
    task_id='wait_for_people_file',
    filepath=dir_path+'/input/people.csv'
)

returns_sensor = FileSensor(
    dag=dag,
    task_id='wait_for_returns_file',
    filepath=dir_path+'/input/returns.csv'
)

joining_files = PythonOperator(
    dag=dag,
    task_id="joining_files",
    python_callable=join_files
)

dimensions_and_fact = PythonOperator(
    dag=dag,
    task_id="creating_dimension_and_fact_csv",
    python_callable=creating_dimension_csv
)

sql_scripts = PythonOperator(
    dag=dag,
    task_id="creating_sql_scripts",
    python_callable=create_sql_scripts
)

orders_script = PostgresOperator(
    postgres_conn_id="postgres_main",
    dag=dag,
    task_id="orders_sql",
    sql="/output/insert_orders.sql",
)

order_details_script = PostgresOperator(
    postgres_conn_id="postgres_main",
    dag=dag,
    task_id="order_details_sql",
    sql="/output/insert_order_details.sql",
)

deliver_script = PostgresOperator(
    postgres_conn_id="postgres_main",
    dag=dag,
    task_id="deliver_sql",
    sql="/output/insert_deliver.sql",
)

ship_script = PostgresOperator(
    postgres_conn_id="postgres_main",
    dag=dag,
    task_id="ship_sql",
    sql="/output/insert_ship.sql",
)

customer_script = PostgresOperator(
    postgres_conn_id="postgres_main",
    dag=dag,
    task_id="customer_sql",
    sql="/output/insert_customers.sql",
)

product_script = PostgresOperator(
    postgres_conn_id="postgres_main",
    dag=dag,
    task_id="product_sql",
    sql="/output/insert_product.sql",
)

cleaning_after = PythonOperator(
    dag=dag,
    task_id="cleaning_after",
    python_callable=clean_after
)

start >> [orders_sensor, people_sensor, returns_sensor]
[orders_sensor, people_sensor, returns_sensor] >> joining_files
joining_files >> dimensions_and_fact
dimensions_and_fact >> sql_scripts
sql_scripts >> [deliver_script, ship_script, customer_script, product_script]
[deliver_script, ship_script, customer_script, product_script] >> orders_script
orders_script >> order_details_script
order_details_script >> cleaning_after
