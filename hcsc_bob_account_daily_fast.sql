
  CREATE OR REPLACE FORCE VIEW "HCSCLND"."HCSC_BOB_ACCT_DAILY" ("AccountRefNumber", "AccountType", "AccountStatus", "SubscriberFirstName", "SubscriberMiddleName", "SubscriberLastName", "SubscriberName", "SubscriberStartDate", "SubscriberEndDate", "PolicyState", "Comments", "AccountNumber", "OpType") AS 
  select "AccountRefNumber","AccountType","AccountStatus","SubscriberFirstName","SubscriberMiddleName","SubscriberLastName","SubscriberName","SubscriberStartDate","SubscriberEndDate","PolicyState","Comments","AccountNumber","OpType" from (

-- This pulls all the updates that also don't have an insert --
SELECT distinct
CONCAT(POLICY_STATE, CASE 
						WHEN PARENT_ACCT_NUM IS NOT NULL AND MKT_SEGMENT = 'TAC' THEN PARENT_ACCT_NUM 
						ELSE ACCT_NUM 
					END) as "AccountRefNumber",
null as "AccountType",
CASE WHEN ACCT_STATUS = 'Active' THEN 'Active'
    ELSE 'Cancelled' END as "AccountStatus",
CASE 
	WHEN PARENT_ACCT_NUM IS NOT NULL AND MKT_SEGMENT = 'TAC' THEN NULL 
	ELSE TRIM(ACCT_FIRST_NAME) 
END as "SubscriberFirstName",
CASE 
	WHEN PARENT_ACCT_NUM IS NOT NULL AND MKT_SEGMENT = 'TAC' THEN NULL 
	ELSE TRIM(ACCT_MID_INITIAL) 
END as "SubscriberMiddleName",
CASE 
	WHEN PARENT_ACCT_NUM IS NOT NULL AND MKT_SEGMENT = 'TAC' THEN 
																CASE WHEN TRIM(PARENT_ACCT_NAME) like '%"%' THEN REPLACE(TRIM(PARENT_ACCT_NAME), '"')
																	WHEN TRIM(PARENT_ACCT_NAME) like '%&%' THEN REPLACE(TRIM(PARENT_ACCT_NAME), '&', 'AND')
																		ELSE TRIM(PARENT_ACCT_NAME) 
																END
	ELSE 
        CASE WHEN TRIM(ACCT_LAST_NAME) like '%"%' THEN REPLACE(TRIM(ACCT_LAST_NAME), '"')
			WHEN TRIM(ACCT_LAST_NAME) like '%&%' THEN REPLACE(TRIM(ACCT_LAST_NAME), '&', 'AND')
			ELSE TRIM(ACCT_LAST_NAME) 
		END
END as "SubscriberLastName",
null as "SubscriberName",
TO_CHAR(TO_DATE(ACCT_EFF_DATE, 'YYYYMMDD'), 'MM/DD/YYYY')  AS "SubscriberStartDate",
TO_CHAR(TO_DATE(ACCT_END_DATE, 'YYYYMMDD'), 'MM/DD/YYYY') AS "SubscriberEndDate",
POLICY_STATE as "PolicyState",
null as "Comments",
CASE 
	WHEN PARENT_ACCT_NUM IS NOT NULL AND MKT_SEGMENT = 'TAC' THEN PARENT_ACCT_NUM 
	ELSE ACCT_NUM 
END as "AccountNumber",

CASE 
    WHEN HCSC_PPRO_BOB_DATA.CREATE_DATE = HCSC_PPRO_BOB_DATA.LAST_UPDT_DATE THEN 'I'
    ELSE 'U'
END AS "OpType"


FROM HCSCLND.HCSC_PPRO_BOB_DATA
WHERE 
LAST_UPDT_DATE = TO_CHAR(SYSDATE, 'YYYYMMDD')
AND LAST_UPDT_DATE != CREATE_DATE
AND 
ACCT_END_DATE <= 22000101
AND ACCT_EFF_DATE <= ACCT_END_DATE
AND ACCT_NUM is not null
AND ((LENGTH(ACCT_NUM) = 6 AND SOURCE_SYSTEM = 'Bluestar') OR (SOURCE_SYSTEM != 'Bluestar' AND LENGTH(ACCT_NUM) = 10 AND ACCT_LAST_NAME is not null AND ACCT_FIRST_NAME is not null))
AND SOURCE_SYSTEM = 'Bluestar'
AND MKT_SEGMENT != 'TAC'
ORDER BY "AccountRefNumber"
) A

                --Turns out the query is vastly quicker with just one subquery--
WHERE (NOT EXISTS (SELECT 1 FROM HCSCLND.HCSC_PPRO_BOB_DATA H
                    WHERE  
                    H.LAST_UPDT_DATE = TO_CHAR(SYSDATE, 'YYYYMMDD')
                    AND H.ACCT_END_DATE <= 22000101
                    AND H.ACCT_EFF_DATE <= H.ACCT_END_DATE
                    AND H.ACCT_NUM is not null
                    AND H.LAST_UPDT_DATE = H.CREATE_DATE
                    AND SOURCE_SYSTEM = 'Bluestar'
                    AND MKT_SEGMENT != 'TAC'
                    AND A."AccountRefNumber" = CONCAT(POLICY_STATE, CASE 
                                                        WHEN PARENT_ACCT_NUM IS NOT NULL AND MKT_SEGMENT = 'TAC' THEN PARENT_ACCT_NUM 
                                                        ELSE ACCT_NUM 
                                                    END)
                    ))
                
UNION

-- This pulls all the new records that don't have an update-- 
select "AccountRefNumber","AccountType","AccountStatus","SubscriberFirstName","SubscriberMiddleName","SubscriberLastName","SubscriberName","SubscriberStartDate","SubscriberEndDate","PolicyState","Comments","AccountNumber","OpType" from (
SELECT distinct
CONCAT(POLICY_STATE, CASE 
						WHEN PARENT_ACCT_NUM IS NOT NULL AND MKT_SEGMENT = 'TAC' THEN PARENT_ACCT_NUM 
						ELSE ACCT_NUM 
					END) as "AccountRefNumber",
null as "AccountType",
CASE WHEN ACCT_STATUS = 'Active' THEN 'Active'
    ELSE 'Cancelled' END as "AccountStatus",
CASE 
	WHEN PARENT_ACCT_NUM IS NOT NULL AND MKT_SEGMENT = 'TAC' THEN NULL 
	ELSE TRIM(ACCT_FIRST_NAME) 
END as "SubscriberFirstName",
CASE 
	WHEN PARENT_ACCT_NUM IS NOT NULL AND MKT_SEGMENT = 'TAC' THEN NULL 
	ELSE TRIM(ACCT_MID_INITIAL) 
END as "SubscriberMiddleName",
CASE 
	WHEN PARENT_ACCT_NUM IS NOT NULL AND MKT_SEGMENT = 'TAC' THEN 
																CASE WHEN TRIM(PARENT_ACCT_NAME) like '%"%' THEN REPLACE(TRIM(PARENT_ACCT_NAME), '"')
																	WHEN TRIM(PARENT_ACCT_NAME) like '%&%' THEN REPLACE(TRIM(PARENT_ACCT_NAME), '&', 'AND')
																		ELSE TRIM(PARENT_ACCT_NAME) 
																END
	ELSE 
        CASE WHEN TRIM(ACCT_LAST_NAME) like '%"%' THEN REPLACE(TRIM(ACCT_LAST_NAME), '"')
			WHEN TRIM(ACCT_LAST_NAME) like '%&%' THEN REPLACE(TRIM(ACCT_LAST_NAME), '&', 'AND')
			ELSE TRIM(ACCT_LAST_NAME) 
		END
END as "SubscriberLastName",
null as "SubscriberName",
TO_CHAR(TO_DATE(ACCT_EFF_DATE, 'YYYYMMDD'), 'MM/DD/YYYY')  AS "SubscriberStartDate",
TO_CHAR(TO_DATE(ACCT_END_DATE, 'YYYYMMDD'), 'MM/DD/YYYY') AS "SubscriberEndDate",
POLICY_STATE as "PolicyState",
null as "Comments",
CASE 
	WHEN PARENT_ACCT_NUM IS NOT NULL AND MKT_SEGMENT = 'TAC' THEN PARENT_ACCT_NUM 
	ELSE ACCT_NUM 
END as "AccountNumber",

CASE 
    WHEN HCSC_PPRO_BOB_DATA.CREATE_DATE = HCSC_PPRO_BOB_DATA.LAST_UPDT_DATE THEN 'I'
    ELSE 'U'
END AS "OpType"


FROM HCSCLND.HCSC_PPRO_BOB_DATA
WHERE 
LAST_UPDT_DATE = TO_CHAR(SYSDATE, 'YYYYMMDD')
AND LAST_UPDT_DATE = CREATE_DATE
AND 
ACCT_END_DATE <= 22000101
AND ACCT_EFF_DATE <= ACCT_END_DATE
AND ACCT_NUM is not null
AND ((LENGTH(ACCT_NUM) = 6 AND SOURCE_SYSTEM = 'Bluestar') OR (SOURCE_SYSTEM != 'Bluestar' AND LENGTH(ACCT_NUM) = 10 AND ACCT_LAST_NAME is not null AND ACCT_FIRST_NAME is not null))

AND SOURCE_SYSTEM = 'Bluestar'
AND MKT_SEGMENT != 'TAC'
ORDER BY "AccountRefNumber"
) A
                  
WHERE (NOT EXISTS (SELECT 1 FROM HCSCLND.HCSC_PPRO_BOB_DATA H
                    WHERE  
                    H.LAST_UPDT_DATE = TO_CHAR(SYSDATE, 'YYYYMMDD')
                    AND H.ACCT_END_DATE <= 22000101
                    AND H.ACCT_EFF_DATE <= H.ACCT_END_DATE
                    AND H.ACCT_NUM is not null
                    AND H.LAST_UPDT_DATE != H.CREATE_DATE
                    AND SOURCE_SYSTEM = 'Bluestar'
                    AND MKT_SEGMENT != 'TAC'
                    AND A."AccountRefNumber" = CONCAT(POLICY_STATE, CASE 
                                                        WHEN PARENT_ACCT_NUM IS NOT NULL AND MKT_SEGMENT = 'TAC' THEN PARENT_ACCT_NUM 
                                                        ELSE ACCT_NUM 
                                                    END)
                    ));
