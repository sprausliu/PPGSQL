--BV≤Ω÷Ë–≈œ¢
select s.batchstep_id
,h.batch_id
,s.batchstep_no
,s.OPRN_NO
--,d.line_no
,s.added_by
,s.date_added
,s.modified_by
,s.batchstep_start_time
,s.date_modified
,s.tank_id
,s.batchstep_rf_status
,d.added_by
,d.modified_by
from MPI_BATCH_VERIFY_TRANS_HDR h
,MPI_BATCH_VERIFY_TRANS_STEP S
,MPI_BATCH_VERIFY_TRANS_DTL d
--,MPI_BATCH_VERIFY_TRANS_DTL d
,gme_batch_header b
where h.batch_key=s.batch_key 
--and s.batchstep_key=d.batchstep_key
and b.batch_id=h.batch_id
and s.batchstep_key=d.batchstep_key
and b.batch_no='MO-JA100087'

select * from MPI_BATCH_VERIFY_TRANS_DTL
