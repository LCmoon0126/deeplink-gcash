SELECT
  DATE(asset_loan_record_create_at) AS '日期',
  COUNT(*) AS '进件总数',
  SUM(
    CASE
      WHEN 
	  asset_loan_record_extend_info <> ''
   	 AND get_json_object(asset_loan_record_extend_info,'$.creditAt') IS NOT NULL
	  THEN 1
      ELSE 0
    END
  ) AS '审核通过总数',
  ROUND(
    SUM(
      CASE
        WHEN asset_loan_record_extend_info <> ''
    	AND get_json_object(asset_loan_record_extend_info,'$.creditAt') IS NOT NULL THEN 1
        ELSE 0
      END
    ) / COUNT(*),
    4
  ) AS '审核通过率',
  SUM(
    CASE
      WHEN asset_loan_record_status = 6 THEN 1
      ELSE 0
    END
  ) AS '放款成功总数',
  ROUND(
    SUM(
      CASE
        WHEN asset_loan_record_status = 6 THEN 1
        ELSE 0
      END
    ) / NULLIF(
      SUM(
        CASE
          WHEN asset_loan_record_extend_info <> ''
    	AND get_json_object(asset_loan_record_extend_info,'$.creditAt') IS NOT NULL THEN 1
          ELSE 0
        END
      ),
      0
    ),
    6
  ) AS '放款成功率',
  ROUND(
    SUM(
      CASE
        WHEN asset_loan_record_status = 6 THEN 1
        ELSE 0
      END
    ) / COUNT(*),
    6
  ) AS '总成功率'
FROM
  dwd_asset_loan_record
WHERE
  asset_loan_record_create_at >= {{startDate}}
  AND asset_loan_record_create_at < date_add({{endDate}}, INTERVAL 1 DAY)
  AND asset_loan_record_channel = 'own_bank'
GROUP BY
  DATE(asset_loan_record_create_at)
ORDER BY 日期;