-- Licensed to the Apache Software Foundation (ASF) under one or more
-- contributor license agreements.  See the NOTICE file distributed with
-- this work for additional information regarding copyright ownership.
-- The ASF licenses this file to You under the Apache License, Version 2.0
-- (the "License"); you may not use this file except in compliance with
-- the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
BEGIN
DECLARE tableID INT = 0;
DECLARE columnID INT = 0;
DECLARE guTableID INT = 0;
DECLARE guColumnID INT = 0;
	IF EXISTS(select * from SYS.SYSCOLUMNS where tname = 'x_policy' and cname='name') THEN
		IF NOT EXISTS(select * from SYS.SYSCONSTRAINT where constraint_name = 'x_policy_UK_name_service') THEN
			select table_id into tableID from SYS.SYSTAB where table_name = 'x_policy';
			select column_id into columnID from SYS.SYSTABCOL where table_id=tableID and column_name = 'name';
			IF NOT EXISTS(select * from SYS.SYSIDXCOL where table_id=tableID and column_id=columnID) THEN
				UPDATE x_policy set name=(name || '-duplicate-' || id) where id in (select id from (select id from x_policy where service || name in (select service || name from x_policy group by service,name having count(*) >1)) as tmp);
				DROP INDEX x_policy_service;
				ALTER TABLE dbo.x_policy DROP CONSTRAINT x_policy_FK_service;
				ALTER TABLE dbo.x_policy ALTER name varchar(512) NOT NULL, ALTER service bigint NOT NULL ;
				ALTER TABLE dbo.x_policy ADD CONSTRAINT x_policy_UK_name_service UNIQUE NONCLUSTERED (name,service);
				ALTER TABLE dbo.x_policy ADD CONSTRAINT x_policy_FK_service FOREIGN KEY(service) REFERENCES dbo.x_service (id);
				CREATE NONCLUSTERED INDEX x_policy_service ON dbo.x_policy(service ASC);
			END IF;
		END IF;
	END IF;
END
GO
