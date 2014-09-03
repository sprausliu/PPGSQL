with batchs1 as (
select bth.batch_id,bth.batch_no, bth.batch_status,bi.item_code,bi.ppg_inv_type Inv_type,bi.PPG_PLANNING_CLASS_GRP cell
from
GME.GME_BATCH_HEADER bth,
GME.GME_MATERIAL_DETAILS dts,
--GMD.FM_FORM_MST_B FMB,
GMD.GMD_ROUTINGS_B ROUT,
ppg.ppg_bi_item_cat_tbl bi
where
bth.batch_id=dts.batch_id
--AND bth.FORMULA_ID=FMB.FORMULA_ID
and bth.ROUTING_ID=ROUT.ROUTING_ID(+)
and dts.item_id=bi.item_id
and bth.plant_code=bi.orgn_code
and bth.batch_no not like '%/S%'
--and FMB.FORMULA_NO<>'RELABEL'
and nvl(ROUTING_CLASS,0)<>'RLBL'
and bi.item_id<>1870
and bi.item_id<>33987
and dts.line_type=1
and TO_CHAR(bth.ACTUAL_START_DATE,'YYYYMMDD')  between (select to_char(next_day(sysdate,2)-14,'yyyymmdd') from dual) and ( select case to_char(sysdate,'D') when '1' then to_char(next_day(sysdate,1)-14,'yyyymmdd') else to_char(next_day(sysdate,1)-7,'yyyymmdd') end from dual)
and bth.plant_code='TJ'
)
,
batchs as (
select cell,batch_id,batch_no,batch_status,item_code,inv_type
from batchs1
where
inv_type<>'04' and cell='TJ E-Coat'
union all
select cell,batch_id,batch_no,batch_status,item_code,inv_type
from batchs1
where
cell<>'TJ E-Coat'
)
,
bv_batchs as (
select batchs.batch_id,bvh.batch_complete_ind
from
batchs,
MPI_OWNER.MPI_BATCH_VERIFY_TRANS_HDR bvh
where
batchs.batch_id=bvh.batch_id
and bvh.BATCH_RESET_IND = 0
)
,
rate as (
select batchs.cell,batchs.batch_no,batchs.item_code,batchs.batch_status,bv_batchs.batch_complete_ind BV_Batch_Completed
from
batchs,
bv_batchs
where
batchs.batch_id=bv_batchs.batch_id(+)
)
select * from rate
