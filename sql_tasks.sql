-- Задание 1
-- Вывести отсортированный по количеству перелетов (по убыванию) и имени (по возрастанию) список пассажиров, совершивших хотя бы 1 полет.
-- https://sql-academy.org/ru/trainer/tasks/16
SELECT name, COUNT(name) count
FROM Passenger
    INNER JOIN Pass_in_trip
    ON Passenger.id = Pass_in_trip.passenger
GROUP BY name
ORDER BY count DESC, name;



-- Задание 2
-- Сколько времени обучающийся будет находиться в школе, учась со 2-го по 4-ый учебный предмет?
-- https://sql-academy.org/ru/trainer/tasks/42
SELECT TIMEDIFF(
    (SELECT end_pair FROM Timepair WHERE id = 4),
    (SELECT start_pair FROM Timepair WHERE id = 2)
    ) time;



-- Задание 3
-- Выведите список комнат, которые были зарезервированы в течение 12 недели 2020 года.
-- https://sql-academy.org/ru/trainer/tasks/61
SELECT Rooms.*
FROM Reservations
    INNER JOIN Rooms
    ON Reservations.room_id = Rooms.id
WHERE YEARWEEK(start_date, 1) = "202012";



-- Задание 4
-- Какой(ие) кабинет(ы) пользуются самым большим спросом?
-- https://sql-academy.org/ru/trainer/tasks/45
SELECT classroom
FROM Schedule
GROUP BY classroom
HAVING count(classroom) = (
    SELECT MAX(count)
    FROM (
        SELECT classroom, COUNT(classroom) count
        FROM Schedule
        GROUP BY classroom
        ) counts
    );
-- ...или тоже самое, но с CTE, просто потому что так читаемее
WITH
    counts AS (SELECT classroom, COUNT(classroom) count
        FROM Schedule
        GROUP BY classroom),
    max_counts AS (SELECT MAX(count) max_c
        FROM counts)
SELECT classroom
FROM counts
    INNER JOIN max_counts
    ON counts.count = max_counts.max_c;



-- Задание 5
-- Для каждой пары последовательных дат, dt1 и dt2, поступления средств (таблица Income_o) найти сумму выдачи денег (таблица Outcome_o) в полуоткрытом интервале (dt1, dt2].
-- Вывод: сумма, левая граница интервала, правая граница интервала.
-- https://www.sql-ex.ru/learn_exercises.php?LN=145
SELECT COALESCE(SUM(out), 0) qty, dt1, dt2
FROM (SELECT date dt1, LEAD(date) OVER(ORDER BY date) dt2
    FROM (SELECT DISTINCT date FROM Income_o) dates) intervals
    OUTER APPLY (SELECT * FROM Outcome_o O WHERE O.date > intervals.dt1 AND O.date <= intervals.dt2) o
GROUP BY dt1, dt2
HAVING dt2 IS NOT NULL
ORDER BY dt1;



-- Задание 6
-- Историки решили составить отчет о битвах в два суперстолбца. Каждый суперстолбец состоит из трёх столбцов (номер битвы, название и дата).
-- Сначала в порядке возрастания номеров заполняется первый суперстолбец, потом - второй. Порядковый номер битве назначается согласно сортировке: дата, название.
-- С целью экономии бумаги, историки делят информацию из таблицы Battles поровну, занося в первый суперстолбец на одну битву больше при их нечетном количестве.
-- В таблицу с шестью колонками вывести результат работы историков, пустые места заполнить NULL-значениями.
-- https://www.sql-ex.ru/learn_exercises.php?LN=130
with
    cols as (SELECT ROW_NUMBER() OVER(ORDER BY date, name) rn, ROW_NUMBER() OVER(PARTITION BY tile ORDER BY date, name) tn, *
    FROM (SELECT NTILE(2) OVER(ORDER BY date, name) tile, * FROM Battles) b)
SELECT t1.rn rn1, t1.name name1, t1.date date1, t2.rn rn2, t2.name name2, t2.date date2
FROM (SELECT * FROM cols WHERE tile = 1) t1
    LEFT JOIN (SELECT * FROM cols WHERE tile = 2) t2
    ON t1.tn = t2.tn;
