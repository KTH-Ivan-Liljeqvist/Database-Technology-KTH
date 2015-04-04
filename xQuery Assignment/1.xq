let $d := doc("mondial.xml")/mondial

let $provinces := (
  for $p in $d/country
  where $p/name[.="Sweden"]
  return $p/province
)

for $pr in $provinces
order by $pr/number(population) descending
return <pro>{ $pr/name, $pr/population, $pr/city[@is_state_cap = "yes"]/name }</pro>