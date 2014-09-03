select aul.batch_no,aul.cell,aul.batchstep_rf_status,aul.date_modified,aul.modified_by,astep.creation_date,astep.batchstep_no,astep.user_name from 
(select bh.batch_id,bvh.batch_key,bh.batch_no,bvs.batchstep_rf_status,bvs.date_modified,bvs.modified_by,bi.PPG_PLANNING_CLASS_GRP as cell
from Mpi_Batch_Verify_Trans_Hdr bvh
,gme_batch_header bh
,mpi_batch_verify_trans_step bvs
,gme_material_details dts
,ppg.ppg_bi_item_cat_tbl bi
where bvh.batch_id=bh.batch_id
and bvh.batch_key=bvs.batch_key
and bh.batch_id=dts.batch_id
and dts.item_id=bi.item_id
and bh.plant_code=bi.orgn_code 
and dts.line_type=1 
and bh.plant_code='TJ'
and bvs.batchstep_no=200
and bi.item_id<>1870 
and bi.item_id<>33987
and bvs.batchstep_rf_status='ÒÑÍê³É'
and to_char(bvs.date_modified,'yyyy/MM/dd')>=to_char(SYSDATE-7,'yyyy/MM/dd')
--and bh.batch_no='MC-103460'
£©aul
,(select h.batch_id,s.creation_date,s.batchstep_no,adu.user_name
from gme_batch_header h
,gme_batch_steps s
,fnd_user adu
where h.batch_id=s.batch_id
and s.created_by=adu.user_id
and s.batchstep_no between 181 and 199
and h.plant_code='TJ'
and to_char(s.creation_date,'yyyyMMdd')>to_char(sysdate-7,'yyyyMMdd')
) astep
where aul.batch_id=astep.batch_id
and astep.creation_date>aul.date_modified