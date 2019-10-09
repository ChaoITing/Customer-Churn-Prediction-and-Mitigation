libname UTD 'C:\Users\ixc171230\Desktop';run;

PROC IMPORT OUT= UTD.crktr 
            DATAFILE= "C:\Users\ixc171230\Desktop\crktr0314.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

proc sort data = UTD.crktr; by ID; run;

/*proc reg data = UTD.crktr;
model churned = tenure		plan_amount		hh_income		ETHNICITY_N		service_type_N	CALLS_1MONTH_TO_DEACT	CALLS_2MONTH_TO_DEACT	CALLS_3MONTH_TO_DEACT total_data	total_messages	total_minutes	sub_lpay_amt	avg_call_duration;
output out = resid p = PUNITS r = RUNITS student = student;
run;quit;

data UTD.crktrR;
set resid;
if student > 3.00 then delete;
if student < -3.00 then delete;
run;
*/
proc standard data=UTD.crktr mean=0 std=1 out=standard;
var 
 data_used_1month	data_1month_to_deact	avg_ivr_duration	num_ivr_calls	total_calls_made_1month	calls_1month_to_deact
sub_lpay_amt	 tenure		hh_income				sub_active_phone_count		ETHNICITY_N	occ	
;
run;
proc fastclus data = work.standard 
maxclusters = 6 out = clus_final (keep = ID cluster);
var	data_used_1month	data_1month_to_deact	avg_ivr_duration	num_ivr_calls	total_calls_made_1month	calls_1month_to_deact
sub_lpay_amt	 tenure		hh_income				sub_active_phone_count		ETHNICITY_N	occ	
;
run;
data final;
merge UTD.crktr clus_final; by ID ; run;
proc discrim data= work.final out=output scores = x method=normal anova;
   class cluster ;
   priors prop;
   id ID;
   var  data_used_1month	data_1month_to_deact	avg_ivr_duration	num_ivr_calls	total_calls_made_1month	calls_1month_to_deact
sub_lpay_amt	 tenure		hh_income				sub_active_phone_count		ETHNICITY_N	occ	;
run;


proc sort data = final; by cluster; run;


proc means data = work.final; by cluster; 
var  data_used_1month	data_1month_to_deact	avg_ivr_duration	num_ivr_calls	total_calls_made_1month	calls_1month_to_deact
sub_lpay_amt	 tenure		hh_income				sub_active_phone_count		ETHNICITY_N	occ	
total_data total_messages total_minutes total_drop_calls data_deact	drop_calls_deact	sms_deact	calls_deact	sub_active_phone_count	churned;
output out = means; run;


data means2;
set means;
where _stat_ = 'MEAN';
run;

proc print data=means2; run;


