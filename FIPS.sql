SELECT A.fips5 as FIPS, State.Disclosure as Disclosure_FLG, IFNULL(Pub.count,0) + IFNULL(MLS.count,0) + IFNULL(Appraisal.count,0) as TotalTransaction_CNT, IFNULL(Pub.count,0) as Public_CNT, IFNULL(MLS.count,0) as MLS_CNT, IFNULL(Appraisal.count,0) as Appraisal_CNT, 'Enriched' as DataSource, current_datetime() as InsertDate
FROM (Select distinct fips5, substr(fips5,1,2) as StateFIPS 
	From `1_ModelX.01_modelx_enriched_data_20200414`) as A
	LEFT JOIN 
	(SELECT fips5, count(fips5) as count FROM `1_ModelX.01_modelx_enriched_data_20200414`,
		UNNEST(valueHistory.list) V
		WHERE V.element.date BETWEEN '2019-3-01' AND '2020-02-29'
		AND V.element.source like '01%'
	GROUP By fips5) as Pub
	ON A.fips5 = Pub.fips5
	LEFT JOIN
	(SELECT fips5, count(fips5) as count FROM `1_ModelX.01_modelx_enriched_data_20200414`,
		UNNEST(valueHistory.list) V
		WHERE V.element.date BETWEEN '2019-3-01' AND '2020-02-29'
		AND V.element.source like '40%'
	GROUP By fips5) as MLS
	ON A.fips5 = MLS.fips5
	LEFT JOIN
	(SELECT fips5, count(fips5) as count FROM `1_ModelX.01_modelx_enriched_data_20200414`,
		UNNEST(valueHistory.list) V
		WHERE V.element.date BETWEEN '2019-3-01' AND '2020-02-29'
		AND ((V.element.source like'10%') or (V.element.source like'11%') or (V.element.source like'12%'))
	GROUP By fips5) as Appraisal
	ON A.fips5 = Appraisal.fips5
	LEFT JOIN `clgx-surveillance-sbx-f577.acheng.DisclosureState` as State
	ON A.StateFIPS = State.FIPS
ORDER by A.fips5 DESC
------
