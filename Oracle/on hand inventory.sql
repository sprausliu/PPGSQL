select bv_use,BATCH_NO,batch_view_v2.CELL
                    ,status_mins/60 as status_hours
                    ,status_mins%60 as status_minutes
                    ,CONVERT(int,plan_qty) as plan_qty
                    ,item_um                 
,grind,board_status,diffmin/60 as hours,diffmin%60 as minutes,item_code,isnull(tank_id,'<NO TANK>') as tank_id,batchstep_no,OPRN_no,grind1,g.batchstep_rf_status,(case when batchstep_rf_status is null and grind='Y' then 'Y' when batchstep_rf_status=N'??' then 'D' when grind='Y' then 'G' else 'N' end) as grind_status 
                    ,(case ua.batch_if_urgent when '0' then 'N' when '1' then 'Y' end) as batch_if_urgent
                    ,ua.urgent_description
                    ,(case when diffmin>cell_CT_mins then 'Y' else 'N' end) as over_ct
                    ,(case when ua.batch_if_quality=1 and quality_expired>getdate() then 'Y' else 'N' end) as qualityissue
                    ,isnull(ua.quality_responsibleby,'None') as quality_responsibleby,ua.quality_description
                    ,(select top 1 username from v_scan_main where loginid=modified_by and lend_date<date_modified and (return_date>date_modified or return_date is null) order by lend_date desc) as operator
                    ,(case when ua.bell_if =1 and datediff(hh,batch_view_v2.actual_start_date,getdate())>=108 then 'br' when ua.bell_if =1 and datediff(hh,batch_view_v2.actual_start_date,getdate())>=84 and datediff(hh,batch_view_v2.actual_start_date,getdate())<108 then 'by' when ua.bell_if =1 and datediff(hh,batch_view_v2.actual_start_date,getdate())<84 then 'bg' end) as bellstatus
                    from batch_view_v2 left join batch_grind_status g on batch_view_v2.batch_id=g.batch_id
                    LEFT JOIN batch_urgent_alert ua on batch_view_v2.batch_id=ua.batch_id
                    where batch_view_v2.cell='TJ Waterborne'