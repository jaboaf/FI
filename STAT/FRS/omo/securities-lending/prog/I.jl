#OGRAM

# securities lending data
#is provided by quarter
#in an .xls file
#as of the 3rd quarter of 2010
#2 years after the quarter end

#observations
D=[
("sec_lending_data_2010_q3.xls", "A4:N6705", "A3:B17");
("sec_lending_data_2010_q4.xls", "A4:N9249", "A3:B17");
("sec_lending_data_2011_q1.xls", "A4:N11577", "A3:B17");
("sec_lending_data_2011_q2.xls", "A4:N14448", "A3:B17");
("sec_lending_data_2011_q3.xls", "A4:N14091", "A3:B17");
("sec_lending_data_2011_q4.xls", "A4:N14850", "A3:B17");
("sec_lending_data_2012_q1.xls", "A4:N14770", "A3:B17");
("sec_lending_data_2012_q2.xls", "A4:N13206", "A3:B17");
("sec_lending_data_2012_q3.xls", "A4:N12078", "A3:B17");
("sec_lending_data_2012_q4.xls", "A4:N9521", "A3:B17");
("sec_lending_data_2013_q1.xls", "A4:N10288", "A3:B17");
("sec_lending_data_2013_q2.xls", "A4:N13524", "A3:B17");
("sec_lending_data_2013_q3.xls", "A4:N10892", "A3:B17");
("sec_lending_data_2013_q4.xls", "A4:N11887", "A3:B17");
("sec_lending_data_2014_q1.xls", "A4:N11725", "A3:B17");
("sec_lending_data_2014_q2.xls", "A4:N11578", "A3:B17");
("sec_lending_data_2014_q3.xls", "A4:N12143", "A3:B17");
("sec_lending_data_2014_q4.xls", "A4:N13014", "A3:B17");
("sec_lending_data_2015_q1.xls", "A4:N12228", "A3:B17");
("sec_lending_data_2015_q2.xls", "A4:N12582", "A3:B17");
("sec_lending_data_2015_q3.xls", "A4:N12733", "A3:B17");
("sec_lending_data_2015_q4.xls", "A4:N12941", "A3:B17");
("sec_lending_data_2016_q1.xls", "A4:N13190", "A3:B17");
("sec_lending_data_2016_q2.xls", "A4:N16735", "A3:B17");
("sec_lending_data_2016_q3.xls", "A4:N19335", "A3:B17");
("sec_lending_data_2016_q4.xls", "A4:N19323", "A3:B17");
("sec_lending_data_2017_q1.xls", "A4:N17928", "A3:B17");
("sec_lending_data_2017_q2.xls", "A4:N18463", "A3:B17");
("sec_lending_data_2017_q3.xls", "A4:N19563", "A3:B17");
("sec_lending_data_2017_q4.xls", "A4:N18598", "A3:B17");
("sec_lending_data_2018_q1.xls", "A4:N18935", "A3:B17");
("sec_lending_data_2018_q2.xls", "A4:N18783", "A3:B17");
("sec_lending_data_2018_q3.xls", "A4:N16732", "A3:B17");
("sec_lending_data_2018_q4.xls", "A4:N14348", "A3:B17");
("sec_lending_data_2019_q1.xls", "A4:N14472", "A3:B17");
("sec_lending_data_2019_q2.xls", "A4:N15746", "A3:B17");
("sec_lending_data_2019_q3.xls", "A4:N18024", "A3:B17");
("sec_lending_data_2019_q4.xls", "A4:N17967", "A3:B17");
("sec_lending_data_2020_q1.xls", "A4:N21346", "A3:B17");
("sec_lending_data_2020_q2.xls", "A4:N20236", "A3:B17");
("sec_lending_data_2020_q3.xls", "A4:N17099", "A3:B17");
("sec_lending_data_2020_q4.xls", "A4:N16904", "A3:B17");
("sec_lending_data_2021_q1.xls", "A4:N17086", "A3:B17");
("sec_lending_data_2021_q2.xls", "A4:N18972", "A3:B17");
("sec_lending_data_2021_q3.xls", "A4:N19138", "A3:B17");
("sec_lending_data_2021_q4.xls", "A4:N21849", "A3:B17")]

#using statements usually go at the top of a program file
using Dates
using ExcelReaders

Cn=[]
Ct=[]
I=[]

#Read data from sheet 1 of each file in relevant range (observed)
for d in D
	b=readxl("../data/"*d[1],openxl("../data/"*d[1]).workbook.sheet_names()[1]*"!"*d[2])
	push!(Cn,b[1,:])
	push!(Ct,[ b[2:end,i].|>typeof|>unique for i in 1:size(b,2)])
	push!(I,b[2:end,:])
	println("done w $("../data/"*d[1])")
end

# DUMP ~column names~ into MD
#This rly is not important after you look at it once. There are slight labelling variations.
open("../stat/sec_lending_data_1!(A-N)[4].md","w") do io
	print(io,"|index of sheet","|file",'|', (('A' : 'N') .* "4|" )...,(('A' : 'N') .* "|")...)
	print(io,"\n|")
	print(io,"---|"^30)
	print(io,("\n|1|" .* first.(D) .* "|" .* join.(Cn,"|") .* "|" .* join.(Ct,"|") .* "|")...)
end

# ascertain:there are multiple identical transactions
@assert any(size.(unique.(I,dims=1),1) .== size.(I,1))

# ascertain:there are not multiple identical transactions every quarter 
@assert !all(size.(unique.(I,dims=1),1) .== size.(I,1))

# ascertain:Trade date is always the same as Settlement date
@assert all(a->a[:,1]==a[:,2],I) "!(all(a->a[:,1]==a[:,2],I)) #Trade date is not always the same as Settlement date"
#Trade date is always the same as Settlement date

# joining formats
## of datestamps. E.g. Trade dates, Settlement dates, Maturity date, "Actual" return dates.
#here: embarking on adventures with this data, supposing it is an apparently real (true) record
#?choice! coerce DateTimes into Dates (,then consider, how un-applicable)
#?choice! interpret words as Dates in <u d y> form
for i in findall(a->all(a[1:4] .== [[DateTime]]),Ct)
	I[i][:,1:4] = Date.(I[i][:,1:4])
end
for i in findall(a->all(a[1:4] .== [[String]  ]),Ct)
	I[i][:,1:4] = Date.(I[i][:,1:4],DateFormat("u d Y"))
end
#permission
@assert typejoin(DateTime,String) == Any

## of values of time elapsation measures.
#?choice! a whole number of days isa whole number
#?choice! words over base 10 digits are whole numbers
for i in findall(a-> a[5] == [String],Ct)
	I[i][:,5] = parse.(Int,I[i][:,5])
end
for i in findall(a-> a[5] == [Float64] ,Ct)
	I[i][:,5] = round.(Int,I[i][:,5])
end
#permission
@assert typejoin(String,Float64) == Any


ct=[mapslices(a->a.|>typeof|>unique,J,dims=[1]) for J in I]
@assert length(unique(ct))==1 "!(length(unique(ct))==1) #havent normalized or joined or permissably uniformized"
ct=vec(first(unique(ct)))
open("../stat/sec_lending_data!(A-N)typecoersion.md","w") do io
	println(io, '|',join('A' : 'N',"|" ),'|')
	println(io,'|',"---|"^14)
	print(io, '|',join(ct,"|"),'|')
end

I = vcat(I...)
# ascertain: Enforcement of 1_000_000 USD Principal Value bid increment policy
@assert all(mod.(I[:,6],1) .== 0)
# ascertain: lending fees are a whole number, greater than 4, of basis points
@assert I[:,11].|>(x->round(x,digits=2)==x && x > 0.04)|>all
# ascertain: Penalty fees are nil or a whole number of united states cents (i.e. measured by cents)
@assert ((I[:,12].|>(x->round(x,digits=2)!=x)|>findall) .+ 4) == [45, 133, 134, 138, 315, 376, 607, 887, 889, 891, 893, 895, 896, 905, 1124, 1261, 1268, 1273, 1313, 1321, 1432, 1528, 1586, 2303, 2312, 2368, 2575, 2728, 3679, 4052, 4053, 4058, 4066, 4152, 4360, 4366, 4367, 4431, 5046, 5177, 5415, 5576, 5630, 5648, 6044, 6148, 6255, 6432]
## some Penalty fees are non-nil and not a whole number of unites states cents
## result: added to list of questions about the marking of observations 
# ascertain: values of collateral are nil or a whole number of cents 
@assert I[:,14].|>(x->round(x,digits=8)==x && x>=0)|>all

# ascertain: values of securities lent are a whole number of cents 
## positive, yes
@assert (I[:,7] .> 0)|>all
## not whole number of cents, as determined via ExcelReaders module (by xlrd python package ala PyCall)
@assert !(I[:,7].|>(x->round(x,digits=8)==x)|>all)
#counterexamples isolated to sec_lending_data_2010_q3.xls
@assert I[:,7].|>(x->round(x,digits=8)!=x)|>findall.|><(parse(Int,D[1][2][5:end]))|>all
#manually checked in excel that round.(I[:,7],digits=8) = 'sec lending data'!G5:G6705 by writing values of round.(I[:,7],digits=8) to lines of a text file then using excel
I[:,7] = round.(I[:,7],digits=8);


# DUMP I into a markdown table
## if you don't like certain choices or wish to investigate them where I have not or in a way i have not, you have the option to.
## I have taken the liberty to make your life easier, if all your apprehensions occur after the following dump
## And you have the liberty to help your self if any occur prior to this.
## Note the directories we are working within. 
open("../stat/sec_lending_data.md","w") do io
print(io,'|', (('A' : 'N') .* "4|" )...)
print(io,"\n|")
print(io,"---|"^14)
for r in eachrow(I)
print(io,"\n|",r[1],"|",r[2],"|",r[3],"|",r[4],"|",r[5],"|",r[6],"|",r[7],"|",r[8],"|",r[9],"|",r[10],"|",r[11],"|",r[12],"|",r[13],"|",r[14],"|")
end
end


# Peace, welcome to a version of an exploration
## truncatation :/
### leading and trailling whitespace characters of phrases
I[:,findall(==(String),ct)] = strip.(I[:,findall(==(String),ct)]);
## rm non letters from Counterparty values i.e. make them names
I[:,13] = replace.(I[:,13],r"[^A-z]"=>"")
## truncate now or forever hold your peace jojo

# off we go
#NOTE:
#map(s->s[1:findfirst(' ',s)],I[:,9])|>unique|>sort
#["B ","FHL ","FMC ","FNM ","IIB ","IIN ","TB ","TFR ","TN "]
@assert (count.(==(' '),filter(s->s[1]=='B',I[:,9]))|>unique == [1]) "!(count.(==(' '),filter(s->s[1]=='B',I[:,9]))|>unique == [1])"
@assert (2 in count.(==(' '),I[:,9])|>unique) "!(2 in count.(==(' '),I[:,9])|>unique)"
@assert (2 == count.(==(' '),I[:,9])|>unique|>length) "(2 == count.(==(' '),I[:,9])|>unique|>length)"
let desc=map(I[:,9]) do s
	if s[1]!='F'
		if s[1]=='B'
			return "TSY 00.000"*s[2:end]
		elseif s[1]=='I'
			return "IPS"*s[4:end]
		elseif s[2]=='F'
			return "FRN"*s[4:end]
		else
			return "TSY"*s[3:end]
		end
	else
		return s
	end
end
I[:,9]=map(desc) do S
	S[1:11]*"20"*S[18:19]*"-"*S[12:13]*"-"*S[15:16]
end
end
## why do that? bit plainer and i want to

## invertibles 
### transforming values marked in USD to US cents, cents, ¢,
#values in 7th,14th columns as ¢.(Market value of security Lent (in millions, USD), Collateral value (in millions, USD))
#1_000_000.00$ = 1_000_000*100¢
I[:,[7,14]] = round.(Int,I[:,[7,14]]*1_000_000*100)

#values in 12th column as ¢ (Penalty fees (in dollars, USD))
#1.00$ = 100¢
I[:,12] = round.(Int,I[:,12]*100)

### percentage to a number per cent per cent
#so, as part of a whole
I[:,11] = round.(Int,I[:,11]*100)//100//100

### Give Flowers!!! bid increment policy is in force, so make em bid increments
I[:,6] = round.(Int,I[:,6])

# record result
#If your programming requires more than one program life,
#writing it down:
using Serialization; serialize("../stat/I",I);
#and reading it later, in another life, via: deserialize("I",I)
#is faster takes less space than
#-retaining a julia expression that is, or assigns a variable, a literal rval & evaluating it
#-evaluating this file