%let empId= 5713614;
%include "/var/fedex/rmm/cia/public/ra/ra_coe/Richa/pas.sas";
LIBNAME RSLT "/var/fedex/rmm/cia/public/ra/ra_coe/Richa/NClosure_Codes/RSLT";
%let Loc_cd= WASKO;

PROC IMPORT 
DATAFILE="/var/fedex/rmm/cia/public/ra/ra_coe/Richa/NClosure_Codes/RSLT/&Loc_cd._CUST_MAP.xls"
OUT=RSLT.WASKO_CUST_MAP 
DBMS=xls 
REPLACE;

PROC IMPORT 
DATAFILE="/var/fedex/rmm/cia/public/ra/ra_coe/Richa/NClosure_Codes/RSLT/FDX_TA_&Loc_cd..xls"
OUT=RSLT.FDX_TA_WASKO
DBMS=xls 
REPLACE;

PROC IMPORT 
DATAFILE="/var/fedex/rmm/cia/public/ra/ra_coe/Richa/NClosure_Codes/RSLT/COMP_TA_&Loc_cd..xls"
OUT=RSLT.COMP_TA_WASKO
DBMS=xls 
REPLACE;

PROC IMPORT 
DATAFILE="/var/fedex/rmm/cia/public/ra/ra_coe/Richa/NClosure_Codes/RSLT/FDX_RTA_&Loc_cd..xls"
OUT=RSLT.FDX_RTA_WASKO
DBMS=xls 
REPLACE;

PROC IMPORT 
DATAFILE="/var/fedex/rmm/cia/public/ra/ra_coe/Richa/NClosure_Codes/RSLT/COMP_RTA_WASKO.xls"
OUT=RSLT.COMP_RTA_WASKO
DBMS=xls 
REPLACE;

/* Get the Trade Area FedEx Locations */

data RSLT.FDX_TA_WASKO;
set RSLT.FDX_TA_WASKO;
Branded_FDX = FXO+FSL ;
Non_Branded_FDX = ALLN+FOS+FASC+OTH;
DBOX = DBOX;
run;

proc sql;
create table RSLT.FDX_TA_WASKO
 as
(
	select LOC_CD,max(FXO) as FXO,max(FSL) as FSL,max(ALLN) as ALLN,
	max(FOS) as FOS,max(FASC) as FASC,max(OTH) as OTH,
	max(DBOX) as DBOX
	from RSLT.FDX_TA_WASKO

	group by 1
);
quit;

data RSLT.FDX_TA_WASKO;
set RSLT.FDX_TA_WASKO;
array change _numeric_;
        do over change;
            if change=. then change=0;
        end;
Branded_FDX = FXO+FSL ;
Non_Branded_FDX = ALLN+FOS+FASC+OTH;
run;

/* Get the Trade Area UPS Locations */

data RSLT.COMP_TA_WASKO;
set RSLT.COMP_TA_WASKO;
Branded_UPS = UPS_Store + UPS_Customer_Center;
Non_Branded_UPS = UPS_Authorized_Shipping_Outlet+Access_Point_CVS + UPS_Alliance_Shipping_Partner + Access_Point_other + Access_Point_Michaels + Access_Point_Advance_Auto_Parts + UPS_Authorized_Service_Provider;
UPS_Drop_Box = UPS_Drop_Box;
array change _numeric_;
        do over change;
            if change=. then change=0;
        end;
run;

proc sql;
create table RSLT.COMP_TA_WASKO
 as
(
	select LOC_CD,max(UPS_Store) as UPS_Store,
	max(UPS_Customer_Center) as UPS_Customer_Center,
	max(UPS_Authorized_Shipping_Outlet) as UPS_Authorized_Shipping_Outlet,
	max(Access_Point_CVS) as Access_Point_CVS,
	max(UPS_Alliance_Shipping_Partner) as UPS_Alliance_Shipping_Partner,
	max(Access_Point_other) as Access_Point_other,
	max(Access_Point_Michaels) as Access_Point_Michaels,
	max(Access_Point_Advance_Auto_Parts) as Access_Point_Advance_Auto_Parts,
	max(UPS_Authorized_Service_Provider) as UPS_Authorized_Service_Provider,
	max(UPS_Drop_Box) as UPS_Drop_Box
	from RSLT.COMP_TA_WASKO

	group by 1
);
quit;

data RSLT.COMP_TA_WASKO;
set RSLT.COMP_TA_WASKO;
array change _numeric_;
        do over change;
            if change=. then change=0;
        end;
Branded_UPS = UPS_Store + UPS_Customer_Center;
Non_Branded_UPS = UPS_Authorized_Shipping_Outlet+Access_Point_CVS + UPS_Alliance_Shipping_Partner + Access_Point_other + Access_Point_Michaels + Access_Point_Advance_Auto_Parts + UPS_Authorized_Service_Provider;
run;

/* Getting the important metrics */

proc sql;
create table rslt.WASKO_CUST_MAP as select * from (
select USER_EAN, USER_TENDER_TYP_CD, USER_OPCO, USER_CUSTOMER_SIZE, USER_TOTAL_VOLUME, USER_TOTAL_REVENUE,
USER_RETURNS_VOLUME, USER_ADDR_ID, IN_TA, Distance from rslt.WASKO
_CUST_MAP) ; 
quit;


proc sql;
select sum(TOTAL_VOLUME)/254 as TOTAL_ADV, sum(RETURNS_VOLUME)/254 as RETURNS_ADV, 
sum(TOTAL_REVENUE)/254 as TOTAL_ADNR FROM rslt.all_&Loc_cd.;
quit; 

proc sql;
select sum(TOTAL_VOLUME)/254 as SOLD_ADV, sum(TOTAL_REVENUE)/ sum(TOTAL_VOLUME) as sold_yield
FROM rslt.all_&Loc_cd. where TENDER_TYP_CD = 'SOLD';
quit;

proc sql;
select sum(TOTAL_REVENUE)/sum(TOTAL_VOLUME) as DRPF_yield FROM rslt.all_&Loc_cd. 
where TENDER_TYP_CD IN ('DRPF','FSDRPF');
quit;

proc sql;
select sum(TOTAL_VOLUME)/254 as Large_ADV FROM rslt.all_&Loc_cd.
where CUSTOMER_SIZE = 'Large' and TENDER_TYP_CD IN ('DRPF','FSDRPF');
quit;

proc sql;
select sum(TOTAL_VOLUME)/254 as Medium_ADV FROM rslt.all_&Loc_cd.
where CUSTOMER_SIZE = 'Medium' and TENDER_TYP_CD IN ('DRPF','FSDRPF');
quit;

proc sql;
select sum(TOTAL_VOLUME)/254 as Small_ADV FROM rslt.all_&Loc_cd.
where CUSTOMER_SIZE = 'Small' and TENDER_TYP_CD IN ('DRPF','FSDRPF');
quit;

proc sql;
select sum(TOTAL_VOLUME)/254 as Micro_ADV FROM rslt.all_&Loc_cd.
where CUSTOMER_SIZE = 'Micro' and TENDER_TYP_CD IN ('DRPF','FSDRPF');
quit;

proc sql;
select sum(TOTAL_VOLUME)/254 as Catchall_ADV FROM rslt.all_&Loc_cd.
where CUSTOMER_SIZE = 'Catchall' and TENDER_TYP_CD IN ('DRPF','FSDRPF');
quit;

proc sql;
select sum(TOTAL_VOLUME)/254 as UNKNOWN_ADV FROM rslt.all_&Loc_cd. 
where CUSTOMER_SIZE = '' and TENDER_TYP_CD IN ('DRPF','FSDRPF');
quit;

Proc sql;
select service_adnr from rslt.fxo_copy_ADNR_&Loc_cd.;
quit;

Proc sql;
select HOLD_ADV from rslt.HOLD_ADV_&Loc_cd.;
quit;