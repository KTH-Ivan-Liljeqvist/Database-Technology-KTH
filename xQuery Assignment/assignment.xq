(:This assignment uses the Mondial database graciously supplied at: http://www.dbis.informatik.uni-goettingen.de/Mondial/.
Using an XQuery processor (e.g. xqilla) answer all of the following:

1. Show the names, populations and capitals of the provinces (län) of Sweden order by population with largest first.:)

(: get the country :)
let $sweden:=/mondial/country[name="Sweden"]
(: go through each province :)
for $l in $sweden/province
	(: order by population :)
    order by number($l/population) descending
    (: return the values. get the capital of each province by checking is_state_cap attribute :)
return $l/name|$l/population|$l/city[@is_state_cap="yes"]/name

(: 2. Names of the organizations in Europe containing the word 'Nuclear', with an unknown date of establishment. :)

(:Here I loop through all the organizations. I check the headq so that it has an id of a city that is in europe.:)

for $l in mondial/organization[@headq=/mondial/country[encompassed[@continent="europe"]]/province/city/@id]
    return
    (: check so that the name contains Nuclear. The first parameter "." means that we search the entire string :)
    if(not(exists($l/established)) and $l/name[contains(.,'Nuclear')])
    then $l
    (:dont return anything if the name doesnt include Nuclear:)
    else ()






