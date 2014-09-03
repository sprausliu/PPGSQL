--select * from GME.GME_BATCH_HEADER
--
--select * from mpi_owner.MPI_BATCH_VERIFY_TRANS_HDR
--
--select * from mpi_owner.MPI_BATCH_VERIFY_TRANS_STEP step
--
--select * from mpi_owner.MPI_BATCH_VERIFY_TRANS_DTL dtl


with batchs as (
select bth.batch_id,bth.batch_no, bth.batch_status,bi.item_id,bi.item_code,bi.ppg_inv_type Inv_type,bi.ppg_planning_class,bi.PPG_PLANNING_CLASS_GRP cell,bth.ACTUAL_START_DATE,bth.ACTUAL_CMPLT_DATE
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
and nvl(ROUTING_CLASS,0)<>'RCAN'
and bi.item_id<>1870
and bi.item_id<>33987
AND dts.CONTRIBUTE_YIELD_IND='Y'
and dts.line_type=1
and TO_CHAR(bth.ACTUAL_CMPLT_DATE,'YYYYMMDD') between '20140101' and '20140831'
and bth.plant_code='TJ'
)

,
ct180 as (
select hdr.batch_id,step.DATE_MODIFIED
from
batchs,
mpi_owner.MPI_BATCH_VERIFY_TRANS_HDR hdr,
mpi_owner.MPI_BATCH_VERIFY_TRANS_STEP step
where
batchs.batch_id=hdr.batch_id
and hdr.BATCH_KEY=step.BATCH_KEY
and hdr.BATCH_RESET_IND = 0
and step.BATCHSTEP_NO=180
and hdr.PLANT_CODE='TJ'
)
,
CT_Item6 as (
select bth.batch_id,bi.item_id,bth.ACTUAL_START_DATE,bth.ACTUAL_CMPLT_DATE
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
and nvl(ROUTING_CLASS,0)<>'RCAN'
and bi.item_id<>1870
and bi.item_id<>33987
AND dts.CONTRIBUTE_YIELD_IND='Y'
and dts.line_type=1
and to_char(bth.ACTUAL_CMPLT_DATE,'YYYYMMDD') between '20140101' and '20140831'
and bth.plant_code='TJ'
)
,
CT_Item6_avg as (
select CT_Item6.item_id,round(avg(CT_Item6.ACTUAL_CMPLT_DATE-CT_Item6.ACTUAL_START_DATE),2)*24 CT_Item6_avg_Hours
from
CT_Item6
group by CT_Item6.item_id
)
,

ct200 as (
select hdr.batch_id,step.DATE_MODIFIED
from
batchs,
mpi_owner.MPI_BATCH_VERIFY_TRANS_HDR hdr,
mpi_owner.MPI_BATCH_VERIFY_TRANS_STEP step
where
batchs.batch_id=hdr.batch_id
and hdr.BATCH_KEY=step.BATCH_KEY
and hdr.BATCH_RESET_IND = 0
and step.BATCHSTEP_NO=200
and hdr.PLANT_CODE='TJ'
)
,
CT180_6_avg as (
select CT_Item6.item_id,round(avg(ct180.DATE_MODIFIED-CT_Item6.ACTUAL_START_DATE),2)*24 CT180_Item6_avg_Hours
from
CT_Item6,
ct180
where
ct_item6.batch_id=ct180.batch_id(+)
group by CT_Item6.item_id
)
,
CT200_6_avg as (
select CT_Item6.item_id,round(avg(ct200.DATE_MODIFIED-CT_Item6.ACTUAL_START_DATE),2)*24 CT200_Item6_avg_Hours
from
CT_Item6,
ct200
where
ct_item6.batch_id=ct200.batch_id(+)
group by CT_Item6.item_id
)
,
CT200Filling_6_avg as (
select CT_Item6.item_id,round(avg(CT_Item6.ACTUAL_CMPLT_DATE-ct200.DATE_MODIFIED),2)*24 CT200Filling_Item6_avg_Hours
from
CT_Item6,
ct200
where
ct_item6.batch_id=ct200.batch_id(+)
group by CT_Item6.item_id
)
--,
--ct500 as (
--select hdr.batch_id,step.DATE_MODIFIED
--from
--batchs,
--mpi_owner.MPI_BATCH_VERIFY_TRANS_HDR hdr,
--mpi_owner.MPI_BATCH_VERIFY_TRANS_STEP step
--where
--batchs.batch_id=hdr.batch_id
--and hdr.BATCH_KEY=step.BATCH_KEY
--and hdr.BATCH_RESET_IND = 0
--and step.BATCHSTEP_NO=500
--and hdr.PLANT_CODE='TJ'
--)
--,
--CT500_6_avg as (
--select CT_Item6.item_id,round(avg(ct500.DATE_MODIFIED-CT_Item6.ACTUAL_START_DATE),2)*24 CT500_Item6_avg_Hours
--from
--CT_Item6,
--ct500
--where
--ct_item6.batch_id=ct500.batch_id(+)
--group by CT_Item6.item_id
--)
select 
batchs.Actual_cmplt_date,
batchs.cell,batchs.batch_no,batchs.item_code,batchs.Inv_type,batchs.ppg_planning_class,
round((ct180.DATE_MODIFIED-batchs.ACTUAL_START_DATE)*24,2) CT180_Hours,
CT180_6_avg.CT180_Item6_avg_Hours,
round((ct180.DATE_MODIFIED-batchs.ACTUAL_START_DATE)/(batchs.ACTUAL_CMPLT_DATE-batchs.ACTUAL_START_DATE),2) as "CT180_CT%",
round((ct200.DATE_MODIFIED-ct180.DATE_MODIFIED)*24,2) CT200_180_Hours,
CT200_6_avg.CT200_Item6_avg_Hours,
round((ct200.DATE_MODIFIED-batchs.ACTUAL_START_DATE)/(batchs.ACTUAL_CMPLT_DATE-batchs.ACTUAL_START_DATE),2) as "CT200_CT%",
round((batchs.ACTUAL_CMPLT_DATE-ct200.DATE_MODIFIED)*24,2) CT200_Completed_Hours,
CT200Filling_6_avg.CT200Filling_Item6_avg_Hours,
round((batchs.ACTUAL_CMPLT_DATE-ct200.DATE_MODIFIED)/(batchs.ACTUAL_CMPLT_DATE-batchs.ACTUAL_START_DATE),2) as "CT200Filling_CT%",
round((batchs.ACTUAL_CMPLT_DATE-batchs.ACTUAL_START_DATE)*24,2) Total_CT,
CT_Item6_avg.CT_Item6_avg_Hours
from
batchs,
ct180,
CT_Item6_avg,
ct200,
CT180_6_avg,
CT200_6_avg,
CT200Filling_6_avg
where
batchs.batch_id=ct180.batch_id(+)
and batchs.item_id=CT_Item6_avg.item_id(+)
and batchs.batch_id=ct200.batch_id(+)
and batchs.item_id=CT180_6_avg.Item_id(+)
and batchs.item_id=CT200_6_avg.Item_id(+)
and batchs.item_id=CT200Filling_6_avg.Item_id(+)
