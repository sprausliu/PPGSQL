select distinct d.tank_id, h.batch_no,s.batchstep_no,d.line_no,d.item_id,d.date_added
,bci.item_code
,bci.cell
,bci.actual_start_date batch_start 
from MPI_BATCH_VERIFY_TRANS_HDR h
,mpi_batch_verify_trans_step s
,mpi_batch_verify_trans_dtl d
,(select bh.batch_id
,bh.batch_no
,bi.item_code
,bi.PPG_PLANNING_CLASS_GRP  cell
,bi.ppg_inv_type
,bh.actual_start_date
 from gme_batch_header bh
,GME.GME_MATERIAL_DETAILS dts
,ppg.ppg_bi_item_cat_tbl bi
where bh.batch_id=dts.batch_id
and dts.item_id=bi.item_id
and dts.line_type=1
and bi.item_id<>1870 
and bi.item_id<>33987
and bh.plant_code='TJ'
and dts.plan_qty>0
and dts.wip_plan_qty>0
) bci
where h.batch_key=s.batch_key
and h.batch_id=bci.batch_id
and d.batchstep_key=s.batchstep_key
and d.tank_id in ('AUTO-SOLID-4202')
and to_char(d.date_added,'yyyyMMdd')>='20140310'


