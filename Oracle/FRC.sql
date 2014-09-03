select bi.PPG_PLANNING_CLASS_GRP cell
,bth.batch_id
,bth.batch_no
,bth.batch_status Status
,bi.item_code
,bi.item_id
,bth.actual_start_date
,bi.ppg_inv_type
,bi.ppg_planning_class
,round(dts.plan_qty,6) plan_qty
,dts.item_um
,ast.cs
from GME.GME_BATCH_HEADER bth
,GME.GME_MATERIAL_DETAILS dts
--,GMD.FM_FORM_MST_B FMB
,ppg.ppg_bi_item_cat_tbl bi
,(select h.batch_id,count(s.batchstep_id) cs
from gme.gme_batch_header h,
(select batch_id,batchstep_id from
gme_batch_steps
where
 batchstep_no between 181 and 199
) s
where h.batch_id=s.batch_id(+)
and h.batch_status>2
and h.plant_code='TJ'
--and to_char(h.actual_start_date,'yyyymmdd') between '20140501' and '20140531'
group by h.batch_id) ast
where bth.batch_id=dts.batch_id
--AND bth.FORMULA_ID=FMB.FORMULA_ID
and bth.batch_id=ast.batch_id
and dts.item_id=bi.item_id
and bth.plant_code=bi.orgn_code
and bi.item_id<>1870
and bi.item_id<>33987
and dts.line_type=1
--and FMB.FORMULA_NO<>'RELABEL'
--and bth.batch_no='BVTEST02072'
and bth.batch_status>2
and bth.plant_code='TJ'
and dts.plan_qty>0
and dts.wip_plan_qty>0
--and bi.ppg_inv_type in (2,3,4)
and to_char(bth.actual_start_date,'yyyymmdd') between '20140801' and '20140831'