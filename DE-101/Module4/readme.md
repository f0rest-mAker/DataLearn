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
  
## Свой мини-проект
В качестве мини-проекта я захотел попробовать создать систему отчетности для отслеживания активности игроков в тех или иных событиях в игре.
### Причина создания системы отчетности
Несколько месяцев назад я решил скачать одну игру стратегию, которую играл в детстве. Эта игра называлась "Clash of Clans", где игроки улучшают свою деревню, атакуя вражеские деревни и участвуя в различных событиях, после вступления в какой-то клан. Когда ты находишься в клане, каждую неделю на протяжении 3 дней можешь участвовать в так называемых рейдах и получать за эту валюту, которую можно тратить на улучшение столичных деревень (общие деревни для всего клана). В каждом клане глава хочет, чтобы каждый игрок сделал рейды, и для этого ему или соруководителю клана приходится каждый раз смотреть игровой список, где находяться игроки, проделавшие атаки, и сверяться с списком участников клана. Делать это вручную конечно муторно и долго. Так как я в это время проходил данный модуль, то решил попробовать создать систему отчетности для отслеживания участия игроков в рейдах.
### Источник данных
Для построния системы отчетности, нужны данные. Для этого я решил использовать API из официального сайта игры: [Clash of Calns API](https://developer.clashofclans.com/#/), где нужно пройти регистрацию и создать API токен для возможности скачивания JSON файлов с данными об клане.  
  
<img src="https://github.com/f0rest-mAker/DataLearn/blob/main/DE-101/Module4/img/API_my_account.png" width="520">  
  
После регистрации заходим в раздел "My Account" и создаем API ключ, указав имя, описание и допускаемые IP адреса для этого токена, который можем скопировать, нажав но созданный ключ.  
  
<img src="https://github.com/f0rest-mAker/DataLearn/blob/main/DE-101/Module4/img/API_create_key.png" width="600">  
  
<img src="https://github.com/f0rest-mAker/DataLearn/blob/main/DE-101/Module4/img/API_key_example.png" width="600">  

После этого можем перейти в раздел "Documentation" рассмотреть какие данные можем забрать из этого сайта. Мы будем брать информацию об участниках клана (`/clans/{clanTag}/members/`) и о рейдах (`/clans/{clanTag}/capitalraidseasons/`).  

<img src="https://github.com/f0rest-mAker/DataLearn/blob/main/DE-101/Module4/img/API_documentation.png" width="600">  
  
Осталось написать DAG, который загружает, обрабатывает и загружает данные в БД и Google Sheet. Код написан [тут](https://github.com/f0rest-mAker/DataLearn/blob/main/DE-101/Module4/Airflow%20DAGs/clan_info.py). DAG выглядит следующим образом:  

<img src="https://github.com/f0rest-mAker/DataLearn/blob/main/DE-101/Module4/img/Clash_DAG.png" width="1000">  

DAG состоит из начальной задачи (`DummyOperator`), трех групп задач, каждый из которых делает свои задачи, а также финальной задачи, которая отвечает за закрытие поключения.  
Логика работы DAGа такова:
1) Сначала запускается группа задач, которая отвечает за скачивание JSON файлов с помощью API и их сохранение в локальной машине.
2) После этого последовательно выполняются задачи из групп по работе с участниками клана и с информацией про рейды. Очередь начинается с группы задач по работе с участниками клана. В этих задачах происходит чтение JSON файлов, выделение нужных объектов, их сохранение / обновление в БД и Google Sheet.  
  Стоит отметить, как обновляются данные про рейды. Если окажется, что в БД нет никаких данных про рейды, то мы добаляем туда последний активный рейд, если текущее время меньше конца последнего рейда, то обновляем имеющиеся данные про этот рейд, если же окажется, что текущее время больше времени окончания рейда, то мы "закрываем" этот рейд (ставим статус конец, делаем последнее обновление и обновляем время последнего обновления), если время последнего обновления меньше времени окончания рейда, иначе пропускаем все последующие задачи этой группы. Если окажется, что текущее время находится между временами начала и конца рейда, то добавляем новую информацию про рейд.
3) После выполнения группы задач, выполняем задачу, которая закрывает подключение.  
Может появится вопрос, зачем сохранять в Google Sheet, если данные уже сохраняются в БД? Делаем это из-за того, что моя БД находится на локальном сервере, а Tableau Desktop, которая находится у меня на компьюторе, не может подключаться к локальным базам данных, поэтому приходится сохранять их в Sheets, чтобы данные дошли до стадии визуализации. Можно сохранять в csv файлы, однако пришлось бы каждый раз загружать эти данные, а так нам хватит нажать 1 кнопку, чтобы обновить данные.
