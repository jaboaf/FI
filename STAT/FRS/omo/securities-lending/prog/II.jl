# A focus (OPEN LEGs)
# let Q = Million USD par of sec lent
using Serialization
#I[:,[2,9,11,6,7,14]] ~ transactionwise: legdate|sec desc|lending fee rate|Q|mrkval|mrkcollateral|

K = 
let J = sortslices(deserialize("I")[:,[2,9,11,6,7,14]],dims=1)
	# Reduction
	# at [2,9,11]-classes
	# of [6,7,14]
	# by +
	K = [J[1,:]]
	rcnt = J[1,1:3]
	frnt = iterate(eachrow(J),1)
	while frnt != nothing
		(hing,t) = frnt
		#if hing[1:3] == rcnt
		if hing[2]==rcnt[2] && hing[3]==rcnt[3] && hing[1]==rcnt[1]
			K[end][4:6] += hing[4:6]
			frnt = iterate(eachrow(J),t)
		else
			push!(K,hing)
			rcnt = hing[1:3]
			frnt = iterate(eachrow(J),t)
		end
	end
	permutedims(hcat(K...),[2,1]);
end
# ~ sec loan wise: total Q | total mrkval | total mrkcollateral
# ~ date|sec|lendingfeerate|total Q| mrk Q sec lent| mrk collaateralization of Q sec lent