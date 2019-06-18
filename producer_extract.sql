SELECT CON.ContractId as producer_id,
    P.ProducerId as producer_npn,
    PV.Name as producer_name,
    pr_type.DisplayValue as producer_type_name,
    pr_sub_type.DisplayValue as producer_sub_type_name,
    pr_status.DisplayValue as producer_status_name,
    PV.NameLast as producer_last_name,
    PV.NameFirst as producer_first_name,
    PV.NameMid as producer_middle_name,
    null as producer_prefix_name,
    PV.NameSuffix as producer_suffix_name,
    pr_sub_status.DisplayValue as producer_sub_status_name,
    to_char(to_date(CON.DateEff,'YYYYMMDD'),'MM/DD/YYYY') as Original_Status_Effective_Date,
    --to_char(to_date(CVER.DateExp,'YYYYMMDD'),'MM/DD/YYYY') as Original_Status_End_Date,
    case when (CON.ContractStatusCd='tv' and CON.TermVestedDateEff is not null) 
    then to_char(to_date(CON.TermVestedDateEff,'YYYYMMDD'),'MM/DD/YYYY')
    else to_char(to_date(CON.DateExp,'YYYYMMDD'),'MM/DD/YYYY') end as Original_Status_End_Date,
    ex_agreement.DisplayValue as Agreement_Type_Name,
    null as agreement_sub_type_name,
    CON.AlternateId as state_farm_id,
    null as previous_agent_name,
    COV.WebAddress as web_address,
    to_char(to_date(CON.LastAgreementSignedDate,'YYYYMMDD'),'MM/DD/YYYY') as gbap_original_date,
    null as ghs_contracted_name,
    case when COV.ContEmail is null then 'noemail@noemail.com' else COV.ContEmail end as email_address,
    COV.ContPhone as phone_number,
    COV.ContFax as fax_number,
    null as toll_free_number,
    case when CON.NameDba is null then 'N' else 'Y' end as DBA_indicator,
    CON.NameDba as doing_business_as_name,
    case when PBV.PaymentType = 'E' then 'EFT'
         when PBV.PaymentType = 'C' then 'CHK' else null end as payment_type,
    case when PBV.PaymentFrequency = 'm' then 'Monthly'
         when PBV.PaymentFrequency = 'q' then 'Quarterly' else null end as payment_frequency,
    case when print_freq.DisplayValue is null then 'No Printed Statement' else print_freq.DisplayValue end as StatementPrintedFrequency,
    case when CON.IssuePaymentIndicator is null then 'N'
         when CON.IssuePaymentIndicator = 0 then 'N' else 'Y' end as issue_payment_rollup_indicator,
    to_char(to_date(CON.PymtRollupEffDate,'YYYYMMDD'),'MM/DD/YYYY') as payment_rollup_effective_date,
    C_ROLL.ContractID as payment_rollup_producer_number,
    P_ROLL.ProducerId as payment_rollup_producer_npn,
    null as blue_access_indicator,
    null as blue_access_role_name,
    null as Renewal_Method_Of_Delivery,
    null as Alternate_Languages,
    --Changed per Nadeem's request
    null as producer_comment,
    source.DisplayValue as Source_Application_Name,
    case when CON.ProducerType = 'ga' then CON.Region else null end as ga_region,
    case when CON.ProducerType = 'ga' then CON.District else null end as ga_district,
    case when CON.ProducerType = 'ga' then CON.HCSCCluster else null end as ga_cluster,
    contract_state.DisplayValue as organization_name,
    contract_state.DisplayValue||'1' as corp_entity_code,
    case when PV.Individual = 1 then 'Y' else 'N' end as Individual_Indicator,
    case when CON.principal = 1 then 'Y' else 'N' end as principal_indicator,
    to_char(to_date(CON.lstdate,'YYYYMMDD'),'MM/DD/YYYY')||' '||to_char(to_timestamp(to_char(CON.lsttime,'099999999'),'HH24MISSFF3'),'HH:MI:SS.FF3 AM') as last_modified_timestamp,
    CON.lstuser as last_modified_by_id,
    to_char(to_date(nvl(CON.fstdate, CON.lstdate),'YYYYMMDD'),'MM/DD/YYYY')||' '||to_char(to_timestamp(to_char(nvl(CON.fsttime, CON.lsttime),'099999999'),'HH24MISSFF3'),'HH:MI:SS.FF3 AM') as create_timestamp,
    CON.fstuser as create_by_name,
    case when CON.AddedToEmailList is null then 'N'
         when CON.AddedToEmailList = 0 then 'N' else 'Y' end as AddedToEmailList,
    case when CON.AddedToMailList is null then 'N'
         when CON.AddedToMailList = 0 then 'N' else 'Y' end as AddedToMailList,
    case when CON.u65 is null then 'N'
         when CON.u65 = 0 then 'N' else 'Y' end as u65
  
  FROM Producer P

       INNER JOIN ProducerVer PV
          ON PV.ProducerNo = P.ProducerNo
         AND PV.Prosta <> 9
    
  --new join to combine Contract and ContractVer to get rid of duplicates
    INNER JOIN (SELECT C.ProducerNo, C.ContractNo, C.ContractId, C.ContractState, C.AlternateId, C.Region, C.District, C.HCSCCluster, CVER.DateEff, CVER.DateExp, 
      CVER.TermVestedDateEff, CVER.LastAgreementSignedDate, CVER.NameDba, CVER.IssuePaymentIndicator, CVER.ExecutedAgreement, CVER.PaymentRollupNo,
      CVER.ContractStatusCd, CVER.ProducerSubStatus, CVER.ProducerType, CVER.ProducerSubType, CVER.principal, 
      CVER.fstdate, CVER.fsttime, CVER.fstuser, CVER.lstdate, CVER.lsttime, CVER.lstuser, CVER.PymtRollupEffDate,
      CVER.AddedToEmailList, CVER.AddedToMailList, CVER.u65, CVER.StatementPrintedFrequency, CVER.ApplicationSource
    FROM Contract C
    INNER JOIN ContractVer CVER on C.ContractNo = CVER.ContractNo
      
    WHERE CVER.ProSta <> 9 AND C.ContractType = 'Master'
    AND CVER.ContractStatusCd <> 'ia'
    --AND to_char(sysdate,'YYYYMMDD') BETWEEN CVER.dateeff AND CVER.dateexp
    --AND CVER.DateExp = (SELECT MAX(a.DateExp) FROM ContractVer a 
    --                        WHERE a.ContractNo = c.ContractNo and a.ProSta <> 9)
    AND to_char(to_date(CVER.lstdate,'YYYYMMDD'),'MM/DD/YYYY')||' '||to_char(to_timestamp(to_char(CVER.lsttime,'099999999'),'HH24MISSFF3'),'HH:MI:SS.FF3 AM')
      = (SELECT max(to_char(to_date(a.lstdate,'YYYYMMDD'),'MM/DD/YYYY')||' '||to_char(to_timestamp(to_char(a.lsttime,'099999999'),'HH24MISSFF3'),'HH:MI:SS.FF3 AM'))
      FROM ContractVer a where a.contractno = c.contractno and a.prosta <> 9 and a.dateexp = (select MAX(b.DateExp) FROM ContractVer b 
                            WHERE b.ContractNo = a.ContractNo and b.ProSta <> 9))
        ) CON ON CON.ProducerNo = P.ProducerNo

       -- INNER JOIN Contract C
          -- ON P.ProducerNo = C.ProducerNo
         -- AND C.ContractType = 'Master'

       -- INNER JOIN ContractVer CVER
          -- ON CVER.ContractNo = C.ContractNo
         -- AND CVER.Prosta <> 9
      
      LEFT JOIN Contact CO
         ON P.ProducerNo = CO.ProducerNo
        AND CON.Contractno = CO.ContractNo
        --Umair Khakoo: commented this out from join
        --AND CO.ContactType = 'b'

      LEFT JOIN ContactVer COV
         on COV.contactno = CO.contactno
        AND COV.Prosta <> 9
        and to_char(sysdate,'YYYYMMDD') BETWEEN cov.dateeff AND cov.dateexp
  
      LEFT JOIN PayeeBank PB
          ON P.ProducerNo = PB.ProducerNo
         AND CON.Contractno = PB.ContractNo

       LEFT JOIN PayeeBankVer PBV
          ON PBV.PayeeBankNo = PB.PayeeBankNo
         AND PBV.Prosta <> 9
         and to_char(sysdate,'YYYYMMDD') BETWEEN pbv.dateeff AND pbv.dateexp

       LEFT JOIN Contract C_ROLL
          ON CON.PaymentRollupNo = C_ROLL.ContractNo
         AND C_ROLL.ContractType = 'Master'

       LEFT JOIN Producer P_ROLL
          ON P_ROLL.ProducerNo = C_ROLL.ProducerNo

       LEFT JOIN ProducerVer PV_ROLL
          ON PV_ROLL.ProducerNo = P_ROLL.ProducerNo
         AND PV_ROLL.Prosta <> 9
         and to_char(sysdate,'YYYYMMDD') BETWEEN pv_roll.dateeff AND pv_roll.dateexp

       LEFT JOIN
        (select cv.storedvalue, cvl.displayvalue from codetype ct, codevalue cv, codevaluelang cvl
          where ct.codetypeid = 'PRODUCERTYPE'
            and ct.codetypeno = cv.codetypeno
            and cv.prosta = 1
            and cvl.codevalueno = cv.codevalueno) pr_type
          ON CON.ProducerType = pr_type.storedvalue
  
       LEFT JOIN
        (select cv.storedvalue, cvl.displayvalue from codetype ct, codevalue cv, codevaluelang cvl
          where ct.codetypeid = 'PRODUCERSUBTYPE'
            and ct.codetypeno = cv.codetypeno
            and cv.prosta = 1
            and cvl.codevalueno = cv.codevalueno) pr_sub_type
          ON CON.ProducerSubType = pr_sub_type.storedvalue
  
       LEFT JOIN
        (select cv.storedvalue, cvl.displayvalue from codetype ct, codevalue cv, codevaluelang cvl
          where ct.codetypeid = 'CONTRACTSTATUSCD'
            and ct.codetypeno = cv.codetypeno
            and cv.prosta = 1
            and cvl.codevalueno = cv.codevalueno) pr_status
          ON CON.ContractStatusCd = pr_status.storedvalue
  
       LEFT JOIN
        (select cv.storedvalue, cvl.displayvalue from codetype ct, codevalue cv, codevaluelang cvl
          where ct.codetypeid = 'PRODUCERSTATUSREASON'
            and ct.codetypeno = cv.codetypeno
            and cv.prosta = 1
            and cvl.codevalueno = cv.codevalueno) pr_sub_status
          ON CON.ProducerSubStatus = pr_sub_status.storedvalue

       LEFT JOIN
        (select cv.storedvalue, cvl.displayvalue from codetype ct, codevalue cv, codevaluelang cvl
          where ct.codetypeid = 'EXECUTEDAGREEMENT'
            and ct.codetypeno = cv.codetypeno
            and cv.prosta = 1
            and cvl.codevalueno = cv.codevalueno) ex_agreement
          ON CON.ExecutedAgreement = ex_agreement.storedvalue

      LEFT JOIN
        (select cv.storedvalue, cvl.displayvalue from codetype ct, codevalue cv, codevaluelang cvl
          where ct.codetypeid = 'HCSCSTATECODES'
            and ct.codetypeno = cv.codetypeno
            and cv.prosta = 1
            and cvl.codevalueno = cv.codevalueno) contract_state
          ON CON.ContractState = contract_state.storedvalue

      LEFT JOIN
        (select cv.storedvalue, cvl.displayvalue from codetype ct, codevalue cv, codevaluelang cvl
          where ct.codetypeid = 'PRINTFREQUENCY'
            and ct.codetypeno = cv.codetypeno
            and cv.prosta = 1
            and cvl.codevalueno = cv.codevalueno) print_freq
          ON CON.StatementPrintedFrequency = pr_type.storedvalue

      LEFT JOIN
        (select cv.storedvalue, cvl.displayvalue from codetype ct, codevalue cv, codevaluelang cvl
          where ct.codetypeid = 'APPLICATIONSOURCE'
            and ct.codetypeno = cv.codetypeno
            and cv.prosta = 1
            and cvl.codevalueno = cv.codevalueno) source
          ON CON.ApplicationSource = source.storedvalue

WHERE length(CON.ContractId) >= 9
  and to_char(sysdate,'YYYYMMDD') BETWEEN pv.dateeff AND pv.dateexp
  --and CVER.dateexp = (select max(a.dateexp) from contractver a where a.contractno = c.contractno and a.prosta <> 9)
  --and to_char(sysdate,'YYYYMMDD') BETWEEN cver.dateeff AND cver.dateexp
  and PV.TaxId is not null
  and pr_type.DisplayValue is not null
  and pr_status.DisplayValue is not null
  --and CVER.fstdate is not null
  --added this condition that should filter the nulls
  AND CO.ContactType = 'b'