# Модуль 4: Интеграция и трансформация данных - ETL и ELT
## Pentaho Data Integration
Был скачан Pentaho Data Integration, выполнены [задания](https://github.com/f0rest-mAker/DataLearn/tree/main/DE-101/Module4/4.5) из 8 и 9 глав "Pentaho Data Integration Beginner's Guide - Second Edition", а также был построен [Job](https://github.com/f0rest-mAker/DataLearn/tree/main/DE-101/Module4/4.4) для загрузки данных супермаркета из excel файлов в базу данных.
## ETL Подсистемы
В ETL инструменте были найдены следующие ETL подсистемы:  

`1) Error event handler (Обработчик ошибок)`  
 
<img src="https://github.com/f0rest-mAker/DataLearn/blob/main/DE-101/Module4/img/Subsystem_1.png" width="600" height="350">  

`2) Extractiong storage (Подключение к источникам)`  
  
<img src="https://github.com/f0rest-mAker/DataLearn/blob/main/DE-101/Module4/img/Subsystem_2.png" width="600" height="450">  

`3) Deduplication system (Выявление повторов)`  

<img src="https://github.com/f0rest-mAker/DataLearn/blob/main/DE-101/Module4/img/Subsystem_3.png" width="600" height="380">  

`4) Slowly changing dimension processor (Отображение изменений в измерениях)`  

<img src="https://github.com/f0rest-mAker/DataLearn/blob/main/DE-101/Module4/img/Subsystem_4.png" width="720" height="450">  

`5) Surrogate key creation system (Генерация суррогатных ключей для таблиц)`  

<img src="https://github.com/f0rest-mAker/DataLearn/blob/main/DE-101/Module4/img/Subsystem_5.png" width="600" height="300">  

`6) Data integration manager (Загрузка обработанных данных в различные системы)`  

<img src="https://github.com/f0rest-mAker/DataLearn/blob/main/DE-101/Module4/img/Subsystem_6.png" width="600" height="300">  

`7) Sort system (Сортировка)`  

<img src="https://github.com/f0rest-mAker/DataLearn/blob/main/DE-101/Module4/img/Subsystem_7.png" width="600" height="340">  

`8) Parallelizing  / Pipelining System (Параллельная обработка)`  

<img src="https://github.com/f0rest-mAker/DataLearn/blob/main/DE-101/Module4/img/Subsystem_8.png" width="600" height="340">

`9) Problem escalation system (Сообщать об ошибках отправкой сообщений)`  

<img src="https://github.com/f0rest-mAker/DataLearn/blob/main/DE-101/Module4/img/Subsystem_8.png" width="600" height="340">

## Fancy ETL
### Apache Airflow
Apache Airflow - это оркестратор задач с открытым исходным кодом, предназначенный для создания, планирования, мониоринга и оркестрирования потоков операции по обработке данных, для этого он использует направленный ациклический граф (DAG). DAG состоит из задач (task), которые являются экземплярами некоторого класса, написанного на Python. Эти классы обычно называют операторами. Задачи определяют что будет выполняться, а операторы как это будет выполняться. Некоторые примеры операторов: `PythonOperator (выполняет функцию, написанную на Python), BashOperator (выполняет Bash скрипт), PostgresOperator (выполняет некоторый sql скрипт в БД на Postgres)` и т.д. Полный список операторов можно посмотреть в [документации](https://airflow.apache.org/docs/apache-airflow/stable/operators-and-hooks-ref.html). Чтобы установить Airflow потребуется Linux (подойдет WSL, если у вас Windows) или Docker. Запуск, просмотр, некоторые настройки производятся запуском сервера.  
С помощью Airflow был написан [DAG](https://github.com/f0rest-mAker/DataLearn/edit/main/DE-101/Module4/Airflow%20DAGs/orders_dag.py), который выглядит следующим образом:  

![image](https://github.com/f0rest-mAker/DataLearn/blob/main/DE-101/Module4/img/Superstore_DAG.png)  
  
Типы использованных операторов:  
- `DummyOperator` - `start`; точка входа в DAG. Ничего не делает
- `FileSensor` - `wait_for_orders_file; wait_for_people_file; wait_for_returns_file`; сенсор, который запускается, когда появится соответсвующий файл в указанной директории.
- `PythonOperator` - `joining_files; creating_dimension_and_fact_csv; creating_sql_scripts; cleaning_after`; оператор, который запускает функции python (переданные в python_callable) для обработки файлов, а именно объединяет все файлы, создает данные для таблиц измерения и фактоы и пишет sql скрипты, для заполнения таблиц (предворительно очистив таблицу). Самая последняя задача очищает все созданные файлы csv и sql
- `PostgresOperator` - `orders_sql; order_details_sql; deliver_sql; ship_sql; customer_sql; product_sql`; оператор, который запускает sql скрипт в БД, который указан в postgres_conn_id. Чтобы добавить свое соединение к БД, нужно в админ странице (наш запущенный сервер airflow) создать поле, в котором записываются все необходимые данные для подключения (сервер, логин, пароль и т.д.).

Логика работы DAGа такова, сначала он ждет, пока в указанной директории не появятся все нужные файлы, потом объединяет все файлы в одно, дальше этот файл используется для создания измерениии, фактов и sql скриптов для добавления их в БД, после чего выполняются все sql скрипты.  
