with a as
 (select bth.batch_id,
         bth.batch_no,
         bi.PPG_PLANNING_CLASS_GRP cell,
         bi.item_code,
         nvl(step.BATCHSTEP_NO, steps.BATCHSTEP_NO) Step,
         step.BATCHSTEP_RF_STATUS,
         OPER.OPRN_NO,
         dtl.LINE_NO,
         dtl.ITEM_NO,
         dtl.item_um,
         dtl.lot_no,
         dtl.WIP_PLAN_QTY_ORIG,
         dtl.ADD_QTY,
         step.TANK_ID Container,
         usr.DESCRIPTION ADDED_BY,
         nvl(dtl.date_added, step.DATE_MODIFIED) date_added
    from GME.GME_BATCH_HEADER                  bth,
         GME.GME_MATERIAL_DETAILS              dts,
         GME.GME_BATCH_STEPS                   steps,
         mpi_owner.MPI_BATCH_VERIFY_TRANS_STEP step,
         MPI_OWNER.MPI_BATCH_VERIFY_TRANS_HDR  bvh,
         mpi_owner.MPI_BATCH_VERIFY_TRANS_DTL  dtl,
         ppg.ppg_bi_item_cat_tbl               bi,
         GMD.GMD_OPERATIONS_B                  OPER,
         apps.fnd_user                         usr
   where bth.batch_id = dts.batch_id
     and bth.batch_id = steps.batch_id
     and steps.BATCHSTEP_ID = step.BATCHSTEP_ID(+)
     and step.BATCHSTEP_KEY = dtl.BATCHSTEP_KEY(+)
     and bth.batch_id = bvh.batch_id
     and dts.item_id = bi.item_id
     and bth.plant_code = bi.orgn_code
     AND OPER.OPRN_ID = STEPS.OPRN_ID
     and dtl.FND_USER_ID = usr.user_id(+)
     and bvh.BATCH_RESET_IND = 0
     and bi.item_id <> 1870
     and bi.item_id <> 33987
     and steps.BATCHSTEP_NO < 501
     AND dts.CONTRIBUTE_YIELD_IND = 'Y'
     and dts.line_type = 1
     and TO_CHAR(dtl.date_added, 'YYYYMMDD') between '20140303' and
         '20140312'
     and (TO_CHAR(bth.ACTUAL_CMPLT_DATE, 'YYYYMMDD') between '20140303' and
         '20140312' or bth.batch_status = 2)
     and bth.plant_code = 'TJ')
select a.batch_no,
       a.cell,
       a.item_code,
       a.Step,
       a.BATCHSTEP_RF_STATUS Status,
       a.OPRN_NO,
       a.LINE_NO,
       a.ITEM_NO,
       a.item_um UM,
       a.lot_no,
       round(a.WIP_PLAN_QTY_ORIG, 2) WIP_QTY,
       a.ADD_QTY,
       a.Container,
       a.ADDED_BY,
       a.date_added,
       decode(a.Step,
              10,
              '',
              round((a.date_added - lag(a.date_added)
                     over(order by a.batch_id, a.date_added, a.Step)) * 24 * 60,
                    2)) DIFF_Mins
  from a
