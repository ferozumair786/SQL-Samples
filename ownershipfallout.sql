
-- Get all the records where ContractId does not exist
select id.contractid as ProducerID,
 id.ownershippct as DistSplitPercentage,
 id.sourcesystem as Source,
 id.accountnumber,
 id.ownershiptype,
 io.dateeff as PRAssignEffStartDate,
 io.dateexp as PRAssignEffEndDate,
 io.coveragetype,
 io.district,
 io.ownclust,
 io.policyissuestate as PolicyState,
 io.policyrefnumber as PolicyRefID,
 --c.contractid,
 f.infileid,
 'ProducerId Does not Exist' as Error from inownershipdist id
  inner join inownership io on io.inownershipno = id.inownershipno
  inner join infile f on io.infileno = f.infileno
  --left join contract c on id.contractid = c.contractid
  where 
  TO_CHAR(SYSDATE, 'YYYYMMDD') = f.dateff
--   f.dateff between 20191108 and 20191110
  and (f.infileid like 'IMP_BOB_Legacy%' or f.infileid like 'IMP_BOB_Daily%' or f.infileid like 'API_Service_Request%')
  and (io.prosta <> 3 or id.prosta <> 3) 
  --and f.infileid = 'IMP_BOB_Daily_20191109_19:30:02.987'
  and id.contractid not in (select contractid from contract c)
  --order by id.contractid
  
  UNION
  
--   Get all the records where there are duplicates within the same file for an insert
  select id.contractid as ProducerID,
 id.ownershippct as DistSplitPercentage,
 id.sourcesystem as Source,
 id.accountnumber,
 id.ownershiptype,
 io.dateeff as PRAssignEffStartDate,
 io.dateexp as PRAssignEffEndDate,
 io.coveragetype,
 io.district,
 io.ownclust,
 io.policyissuestate as PolicyState,
 io.policyrefnumber as PolicyRefID,
 --c.contractid,
 f.infileid,
 'Duplicate Ownership in File' as Error from inownershipdist id
  inner join inownership io on io.inownershipno = id.inownershipno
  inner join infile f on io.infileno = f.infileno
  --left join contract c on id.contractid = c.contractid
  where 
  TO_CHAR(SYSDATE, 'YYYYMMDD') = f.dateff
--   f.dateff between 20191108 and 20191110
  and (f.infileid like 'IMP_BOB_Legacy%' or f.infileid like 'IMP_BOB_Daily%' or f.infileid like 'API_Service_Request%')
  and (io.prosta <> 3 or id.prosta <> 3) 
  --and f.infileid = 'IMP_BOB_Daily_20191109_19:30:02.987'
  and io.optype = 'I' and (id.contractid, io.policyrefnumber) in (select o.contractid, o.policyrefnumber from inownership o
                                                                  inner join infile inf on o.infileno = inf.infileno 
                                                                  where inf.infileid = f.infileid
                                                                  group by o.contractid, o.policyrefnumber
                                                                  having count(*) > 1)
  --order by id.contractid
  
  UNION
  
--   Get all the records that have an existing Ownership in the system without duplicates in the file itself
  select id.contractid as ProducerID,
 id.ownershippct as DistSplitPercentage,
 id.sourcesystem as Source,
 id.accountnumber,
 id.ownershiptype,
 io.dateeff as PRAssignEffStartDate,
 io.dateexp as PRAssignEffEndDate,
 io.coveragetype,
 io.district,
 io.ownclust,
 io.policyissuestate as PolicyState,
 io.policyrefnumber as PolicyRefID,
 --c.contractid,
 f.infileid,
 'Insert Existing Ownership' as Error from inownershipdist id
  inner join inownership io on io.inownershipno = id.inownershipno
  inner join infile f on io.infileno = f.infileno
  --left join contract c on id.contractid = c.contractid
  where 
  TO_CHAR(SYSDATE, 'YYYYMMDD') = f.dateff
--   f.dateff between 20191108 and 20191110
  and (f.infileid like 'IMP_BOB_Legacy%' or f.infileid like 'IMP_BOB_Daily%' or f.infileid like 'API_Service_Request%')
  and (io.prosta <> 3 or id.prosta <> 3) 
  --and f.infileid = 'IMP_BOB_Daily_20191109_19:30:02.987'
  and io.optype = 'I' and (id.contractid, io.policyrefnumber) in (select contractid, policyrefnumber from ownership where prosta <> 9)
  and (id.contractid, io.policyrefnumber) not in (select o.contractid, o.policyrefnumber from inownership o
                                                                  inner join infile inf on o.infileno = inf.infileno 
                                                                  where inf.infileid = f.infileid
                                                                  group by o.contractid, o.policyrefnumber
                                                                  having count(*) > 1)
  --order by id.contractid
  
  UNION
  
--   Get all records that are updates but there isn't a matching ownership to update
  select id.contractid as ProducerID,
 id.ownershippct as DistSplitPercentage,
 id.sourcesystem as Source,
 id.accountnumber,
 id.ownershiptype,
 io.dateeff as PRAssignEffStartDate,
 io.dateexp as PRAssignEffEndDate,
 io.coveragetype,
 io.district,
 io.ownclust,
 io.policyissuestate as PolicyState,
 io.policyrefnumber as PolicyRefID,
 --c.contractid,
 f.infileid,
 'Update Non Existing Ownership' as Error from inownershipdist id
  inner join inownership io on io.inownershipno = id.inownershipno
  inner join infile f on io.infileno = f.infileno
  --left join contract c on id.contractid = c.contractid
  where 
  TO_CHAR(SYSDATE, 'YYYYMMDD') = f.dateff
--   f.dateff between 20191108 and 20191110
  and (f.infileid like 'IMP_BOB_Legacy%' or f.infileid like 'IMP_BOB_Daily%' or f.infileid like 'API_Service_Request%')
  and (io.prosta <> 3 or id.prosta <> 3) 
  --and f.infileid = 'IMP_BOB_Daily_20191109_19:30:02.987'
  and id.contractid in (select contractid from contract c)
  and io.optype = 'U' and (id.contractid, io.policyrefnumber) not in (select contractid, policyrefnumber from ownership where prosta <> 9)
  --order by id.contractid

  UNION
  
--   catch all the errors that don't fit the above criteria
  select id.contractid as ProducerID,
 id.ownershippct as DistSplitPercentage,
 id.sourcesystem as Source,
 id.accountnumber,
 id.ownershiptype,
 io.dateeff as PRAssignEffStartDate,
 io.dateexp as PRAssignEffEndDate,
 io.coveragetype,
 io.district,
 io.ownclust,
 io.policyissuestate as PolicyState,
 io.policyrefnumber as PolicyRefID,
 --c.contractid,
 f.infileid,
 CASE 
		WHEN io.dateeff > io.dateexp THEN 'PRAssignEffStartDate > PRAssignEffEndDate'
		WHEN io.dateeff = io.dateexp THEN 'Same Day Term'
		ELSE 'Unknown' 
 END AS Error from inownershipdist id
  inner join inownership io on io.inownershipno = id.inownershipno
  inner join infile f on io.infileno = f.infileno
  --left join contract c on id.contractid = c.contractid
  where 
  TO_CHAR(SYSDATE, 'YYYYMMDD') = f.dateff
--   f.dateff between 20191108 and 20191110
  and (f.infileid like 'IMP_BOB_Legacy%' or f.infileid like 'IMP_BOB_Daily%' or f.infileid like 'API_Service_Request%')
  and (io.prosta <> 3 or id.prosta <> 3) 
  --and f.infileid = 'IMP_BOB_Daily_20191109_19:30:02.987'
  and id.contractid in (select contractid from contract c)
  and (id.contractid, io.policyrefnumber) not in (select o.contractid, o.policyrefnumber from inownership o
                                                                  inner join infile inf on o.infileno = inf.infileno 
                                                                  where inf.infileid = f.infileid
                                                                  group by o.contractid, o.policyrefnumber
                                                                  having count(*) > 1)
  and (io.optype = 'U' and (id.contractid, io.policyrefnumber) in (select contractid, policyrefnumber from ownership where prosta <> 9)
  or io.optype = 'I' and (id.contractid, io.policyrefnumber) not in (select contractid, policyrefnumber from ownership where prosta <> 9))