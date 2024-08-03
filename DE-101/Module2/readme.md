## Модуль 2: Базы данных и SQL
В этом модуле познакомились с базами данных (БД), а именно с PostgreSQL, научились подключаться к БД. Также познакомились с облаком, в котором можно создать базу данных и подключаться к нему удалённо через любое устройство.
Домашние задания к данному модулю приведены ниже.  
### 2.1. Знакомство с базами данных.
Задание: установить СУБД PostgreSQL и интерфейс JDBC `DBeaver`.  
- [x] Сделано.  
### 2.2. Подключение к БД.
*Задание:* используя клиент SQL для подключения к БД, создать 3 таблицы для хранения данных из файла первого модуля `Sample - Superstore.xls` и написать запросы для решения заданий из 1 модуля.
*Решение:* 
1) Создаем базу данных через клиент.  
2) Создаем таблицы в БД.
3) Заполняем таблицы, используя DDL из файлов:  
3.1) [orders.sql](https://github.com/f0rest-mAker/DataLearn/blob/9221a0b2dc03db0bc03a0ff04379c4035ca74e4b/DE-101/Module2/2_3/orders.sql).  
3.2) [people.sql](https://github.com/f0rest-mAker/DataLearn/blob/9221a0b2dc03db0bc03a0ff04379c4035ca74e4b/DE-101/Module2/2_3/people.sql).  
3.3) [returns.sql](https://github.com/f0rest-mAker/DataLearn/blob/9221a0b2dc03db0bc03a0ff04379c4035ca74e4b/DE-101/Module2/2_3/returns.sql).
4) Пишем запросы, файлик [тута](https://github.com/f0rest-mAker/DataLearn/blob/9221a0b2dc03db0bc03a0ff04379c4035ca74e4b/DE-101/Module2/2_4/training.sql).
- [x] Сделано.
### 2.3. Модели данных.
*Задача*: Необходимо нарисовать модель данных для файла `Sample - Superstore.xls`. После этого, основываясь на модели данных, создать таблицы и заполнить их запросами SQL.
*Решение*:  
На сайте [SqlBM](https://sqldbm.com/Home/) делаем нашу модель.  
*Концептуальная*:  
![image](https://github.com/f0rest-mAker/DataLearn/blob/9221a0b2dc03db0bc03a0ff04379c4035ca74e4b/DE-101/Module2/screenshots/conceptual.png)  

*Логическая*:  
![image](https://github.com/f0rest-mAker/DataLearn/blob/9221a0b2dc03db0bc03a0ff04379c4035ca74e4b/DE-101/Module2/screenshots/logical.png)  
  
Физическая:  
![image](https://github.com/f0rest-mAker/DataLearn/blob/9221a0b2dc03db0bc03a0ff04379c4035ca74e4b/DE-101/Module2/screenshots/physical.png)  
  
Потом получаем DDL запросы для создания таблиц, а потом заполняем их запросами: [dimensional_modeling.sql](https://github.com/f0rest-mAker/DataLearn/blob/9221a0b2dc03db0bc03a0ff04379c4035ca74e4b/DE-101/Module2/2_4/dimensional_modeling.sql)  
### Дополнение
После выполнения домашних заданий данного модуля и данным рекомендациям по решениям заданий, я вернулся сюда и начал думать, как можно улучшить и оптимизировать данную модель.  
Сперва я заметил, что в первой версии данной модели очень много повторяющихся элементов в таблице `sales_fact`. Я почему-то сразу не заметил, что для каждого заказа один покупатель, одно место прибытие, одно время заказа, доставки, один вид доставки, один менеджер и один вид возврата. Мы знаем, что заказ может содержать несколько товаров, из-за чего идентификатор будет повторяться, а значит в моей модели идентификаторы измерений в таблице фактов будут повторяться, что не очень хорошо, поэтому было принято решение изменить модель данных.  

Концептуальная v2:  
![image](https://github.com/f0rest-mAker/DataLearn/blob/7d1a0a5eef2e8b6766d8678e6efffc05abf6e835/DE-101/Module2/screenshots/conceptual_v2.png)  
  
Логическая v2:
![image](https://github.com/f0rest-mAker/DataLearn/blob/7d1a0a5eef2e8b6766d8678e6efffc05abf6e835/DE-101/Module2/screenshots/logical_v2.png)
В orders будем хранить уникальные идентификаторы заказов и информацию про доставку, покупателя, менеджера и т.д., можно было свзяать менеджера с регионом доставки, но это может разрушить целостность модели, например, что будет если в регионе два менеджера, тогда никак нельзя однозначно связать информацию заказа с менеджером (большое спасибо одному человеку в беседе курса, что рассказал про этот нюанс ^.^), но в этом случае было бы очень хорошо в изначальной таблице заказов, кто именно был менеджером. Таким образом, у нас не будет очень много повторяющихся идентификаторов измерений, а в `order_details` будем хранить всю оставшуюся информацию о метриках, так мы будем иметь быстрый доступ к важным метрикам для бизнеса.    
Физическая v2:  
![image](https://github.com/f0rest-mAker/DataLearn/blob/7d1a0a5eef2e8b6766d8678e6efffc05abf6e835/DE-101/Module2/screenshots/physical_v2.png)  

Благодаря такой модели я убрал повторы и плюсом сократил память, которая нужна для хранения данных.  
Пока в голову пришли только такие изменения, но могут прийти и более оптимизированные по мере изучения данного курса.  
- [x] Сделано.
### 2.4. БД в облаке.
*Задача*: Нужно создать БД в облаке и поиграться с подключениями, запросами.
*Решение*:  
В идеале нужно было создать учетную запись в AWS, однако есть маленькие трудности. Дело в том, что в Amazon теперь нельзя создать российский аккаунт, поэтому нужно было искать альтернативы.  
Альтернативой стал сайт [beget](https://cp.beget.com/), в котором есть 30-ти дневный бесплатный доступ к хостингу. Но опять же, встала ещё одна проблема, бесплатно можно было создать только БД MySQL (+ морока). К счастью, синтаксис у MySQL и PostgreSQL похожий и можно было всё переписать под него.  
Итоговые файлы: [staging.sql](https://github.com/f0rest-mAker/DataLearn/blob/669fae7935b00301b47c87d98f232acbe54e4bf9/DE-101/Module2/2_5/staging.sql), [from_stg_to_dw.sql](https://github.com/f0rest-mAker/DataLearn/blob/669fae7935b00301b47c87d98f232acbe54e4bf9/DE-101/Module2/2_5/from_stg_to_dw.sql).  
Пишем запросы:
![image](https://github.com/f0rest-mAker/DataLearn/blob/1b2362bf1845df64bb9b173a866c09f3d686caac/DE-101/Module2/screenshots/cloud2.png)  
Получаем изменения в облаке:  
![image](https://github.com/f0rest-mAker/DataLearn/blob/1b2362bf1845df64bb9b173a866c09f3d686caac/DE-101/Module2/screenshots/cloud1.png)
  
- [x] Сделано.
### 2.5. Как донести данные до бизнес-пользователя.
*Задача*: Необходимо создать дашборд в одном из решений, которые мы рассмотрели в видеолекции.
*Решение*: Сделаем дашборд в `Google Locker Studio`. Выберем в качестве источников все таблицы нашей модели данных, подключившись к нашей БД в облаке.  
![image](https://github.com/f0rest-mAker/DataLearn/blob/669fae7935b00301b47c87d98f232acbe54e4bf9/DE-101/Module2/screenshots/sources.png)

Сделаем простые дашборды:
![image](https://github.com/f0rest-mAker/DataLearn/blob/669fae7935b00301b47c87d98f232acbe54e4bf9/DE-101/Module2/screenshots/dashb1.png)  
  
![image](https://github.com/f0rest-mAker/DataLearn/blob/669fae7935b00301b47c87d98f232acbe54e4bf9/DE-101/Module2/screenshots/dashb2.png)  
  
![image](https://github.com/f0rest-mAker/DataLearn/blob/669fae7935b00301b47c87d98f232acbe54e4bf9/DE-101/Module2/screenshots/dashb3.png)  
  
- [x] Сделано.
