Общие:
- [X] Исправить ошибки для квесты
- [X] Заставить квесту работать на простом примере ювм
- [X] Добыть ключ квесты для домашнего пк
- [X] Заставить квесту работать на винде
- [ ] Доделать ЮВМ
- [ ] Установить софт для микроконтроллера
- [ ] Забрать микроконтроллер
- [ ] Скачать и добавить в гит метареалы для микроконтреллера
- [ ] Запустить и разобраться во всех примерах их материалов о микре

ЮВМ:
- [X] Сделать простой агент и скорборд
- [X] Сделать управление виртуальным сиквенсером низкоуровневого сиквенсера
- [ ] Сделать скорборд, который будет по низкоуровневому сингалу воссоздавать иначально переданные байты
    - [ ] Если можно, то может проще отправлять транзакции из виртуального сиквенсора

- [X] Вывести recieved_queue_not_empty, transmition_queue_not_full
- [ ] Add status register to fully embrase the bus end (all transactions are like "read from address"/"write to address")
- [ ] Make rx agent monitor read whole bytes
- [ ] Make tx agent read whole bytes via uart interface
- [ ] Split DUT interface into rx, tx and bus
- [ ] Make the test call rx seqencer, then query statua throwgh bus, then when data recieved, send read of data via bus, then write it back, then read from tx analysis port the funal transmitted data and compare with initial.
- [ ] Make bus seqencers

МИКР:
- [ ] 1 пример
...

