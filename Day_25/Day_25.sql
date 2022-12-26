declare @Str varchar(max) =
'1-=022001=-1-
2-1020=0-01=2000
1==-2=122-=2-21102
1-0=1=-0-==0=--=-2
1-0-1=--22=
2=110---012022-21
22==0
2-0-10=112
2210=1-=-1-011=2-
1-=-=0212
1=100011=21101=
2-===02
1--120
1=--1=-000-=00=210
2220=210-01
1=011--1
100212002=0=0
2-=2=0=-00022
200-
1200=
1=1221-01-01-22
1=1=22==-1
1-1=201-
1=10
2
1--2=2=201020-=
1-2-==211=-221=-
100-20=-002=
1-021
20021--=1
2--2=0
1=010=2-=200-01-1
2=1
202102
100-0-0=0-1-
2-
22-12=0010=-221=-
1=1
10--120
1210-020=-1-210=1
102-=1
2=0012=1=10=22-
2=0
1=222
2=-0000=-=11-
1-11-21=02=10
11201---=1=202110
10-1=21202=1=10=0
220102=2110-1
21110101
2--0-0--01-01---2
1=10=1-1-1=0121-=2==
1---=0=10021011
111=1=21
110220==20=2
20--12==20
10-11=1-01
2=-==11=
2==2-
1-0
220=-=-102==
10-0-20
21201=-211001=0-11-
2=020-=20
12=-1---2-=2-02
10=-=20-121
12-
10-02--0=-==
11-
212-2--1-1-=122
1=2-
2020=-1-1002-==-01
2==11201==10-2
200-=-0-0-
1--=====12
12-=02-2-1
21-2=21==10-2=201-
102
111=00
2=-2-0--222=
11--=
2=0-102=2=
1=2-22-=20121-1-12
1-==1-0=--
100
1=0=220002
11-0-2
12
1-020120020
2-==
1020==-02
220=-1
2=-0==-2=021-000
112==
11=1-01=0-2=-10=2==
1=1001
2-=
10-1==1=-2111-=2
1=-0==
2112===0-202=1
102=-
1=12=
1=200=01=22-0
1-2-=2
211220=-01===-1==2
1101-12=--=2020
110001-001-==2='

drop table if exists #Numbers

--Number Table
;with rec as
	(select -15000 Num
	union all
	select Num + 1
	from rec
	where Num <= 15000
	)
select Num
into #Numbers
from rec
option (maxrecursion 32767)
create unique clustered index IX_#Numbers on #Numbers(Num)

;with Input as
	(select row_number() over(order by (select 1)) ID, [value] Val
		from string_split(replace(@Str, char(13), ''), char(10))
	)
	, Digits as
	(select *
		from (values(-2, '=')
					, (-1, '-')
					, (0, '0')
					, (1, '1')
					, (2, '2')
			) v(Val, Digit)
	)
	, dv as
	(select sum(DecVal) DecVal
		from Input
			inner join #Numbers n on Num between 1 and len(Val)
			cross apply (select substring(Val, Num, 1) DigitS, len(Val) - Num Pwr) d
			cross apply (select cast(case DigitS
											when '-' then '-1'
											when '=' then '-2'
										else DigitS
									end as bigint) Digit
						) d1
			cross apply (select power(cast(5 as bigint), Pwr)*Digit DecVal) v
	)
	,rec as
	(select cast(Digit as varchar(max)) Snafu, cast((DecVal - ((DecVal+2)%5-2)) / 5 as bigint) Remainder
		from dv
			inner join Digits on Val = (DecVal + 2)%5 - 2
		union all
		select cast(Digit + Snafu as varchar(max)), cast((Remainder - ((Remainder+2)%5-2)) / 5 as bigint)
		from rec 
			inner join Digits on Val = (Remainder + 2)%5 - 2
		where Remainder > 0
		)
select Snafu Answer1
from rec
where Remainder = 0