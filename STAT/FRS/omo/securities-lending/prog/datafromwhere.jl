# wherefrom.txt is de**lini**ated by "|\n|" and de**limin**ated by "|"
open("../stat/datawherefroms.md", "w") do io
println(io,"|:cmd|cmd|")
print(io,"|---|---|")
for f in filter!(x->x[end-3:end]==".xls",readdir("../data",join=true))
	print(io,"\n|")
	print(io,"mdls -name 'kMDItemWhereFroms' $f -raw |")
	print(io,replace(read(`mdls -name 'kMDItemWhereFroms' $f -raw`, String),r"[\n ]"=>""),"|")
end
end
