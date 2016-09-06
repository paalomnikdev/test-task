-- 1.	Write mysql trigger that update client last Trade id and profit when needed (please explain)
DROP TRIGGER IF EXISTS `client_update`;
DELIMITER @@ -- switch delimiter to write trigger
CREATE TRIGGER `client_update` AFTER INSERT ON `trades` -- give name for trigger, which will works when data inserted to table trades
    FOR EACH ROW BEGIN  -- begin trigger
        SET @total_profit = (SELECT SUM(`t`.`profit`) FROM `trades` as `t` WHERE `t`.`client_id` = NEW.`client_id`); -- gives total profit for a client
        -- client update start (updating last trade id depends on new trade and update profit if it will different from old profit
        UPDATE `clients`
        SET `clients`.`last_trade_id` = NEW.`trade_id`,
        `clients`.`profit` = IF(@total_profit <> `clients`.`profit`, @total_profit, `clients`.`profit`)
        WHERE `clients`.`client_id` = NEW.`client_id`;
        -- client update end
    END;
@@ -- end of trigger using new delimiter
DELIMITER ; -- return of standard delimiter

-- 2.	Write SP that run on all Trades table and insert data to Trades_vt if not exist
DROP PROCEDURE IF EXISTS `trades_sync`;
DELIMITER @@ -- switch delimiter to write procedure
CREATE PROCEDURE `trades_sync` () -- start declare procedure
    BEGIN
        -- variables declare start
        DECLARE t_trade_id integer;
        DECLARE t_amount double;
        DECLARE t_start_time timestamp;
        DECLARE t_end_time timestamp;
        DECLARE t_client_id integer;
        DECLARE t_profit double;
        -- variables declare end

        DECLARE cursor_state integer default 0; -- declare cursor finish flag

        DECLARE `trades_cursor` CURSOR FOR SELECT `t`.`trade_id`, `t`.`amount`, `t`.`start_time`, `t`.`end_time`, `t`.`client_id`, `t`.`profit` FROM `trades` as `t`; -- declare cursor for loop
        DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET cursor_state = 1; -- declare handler when data will end
        OPEN `trades_cursor`;

         -- start loop
        WHILE cursor_state = 0 DO
            -- data sync query start
            FETCH `trades_cursor` INTO t_trade_id, t_amount, t_start_time, t_end_time, t_client_id, t_profit;
            INSERT INTO `trades_vt` (`original_trade_id`, `amount`, `start_time`, `end_time`, `client_id`, `profit`)
            VALUES (`t_trade_id`, `t_amount`, `t_start_time`, `t_end_time`, `t_client_id`, `t_profit`)
            ON DUPLICATE KEY UPDATE `original_trade_id` = `original_trade_id`;
            -- data sync query end
        END WHILE;
        -- end loop
        CLOSE `trades_cursor`;
    END;
@@ -- end procedure using new delimiter
DELIMITER ; -- return of standard delimiter

-- 3.	What is the difference between DATETIME and TIMESTAMP in mysql?
Разница между DATETIME and TIMESTAMP заключается в том, что TIMESTAMP хранит количество секунд, прошедших с 01.01.1970 в UTC и возвращает значение, соответствующее установленному часовому поясу и использует для хранения 4 байта.
DATETIME же всегда хранит одно и то же значение и на него не влияет установленный часовой пояс, занимает 8 байт.