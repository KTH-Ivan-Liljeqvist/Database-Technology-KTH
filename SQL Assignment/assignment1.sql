/*
	author: Ivan Liljeqvist
	version: 31-03-2015

	ASSIGNMENT DESCTIPTION:
	
	In this assignment I had to install Postgre on my system, download Mondial database (http://www.dbis.informatik.uni-goettingen.de/Mondial/), install it and
	complete all of the tasks below.
*/

/*
	1. Show the names, populations and capitals of the provinces (län) of Sweden order by population with largest first.
*/

#Here I need to get the country code of sweden, which I do in the WHERE-clause, I then order the results in descending order by population.
SELECT name,capital,population  FROM province WHERE province.country in (SELECT country.code FROM country WHERE country.name = 'Sweden') ORDER BY population DESC; 


/*
	2. Names of the organizations in Europe containing the word 'Nuclear', with an unknown date of establishment.
*/

#decide which countries are in Europe in the where clause and then check if established==NULL
SELECT * FROM organization WHERE organization.country in (SELECT encompasses.country FROM encompasses WHERE encompasses.continent='Europe') AND organization.name LIKE '%Nuclear%' AND organization.established IS NULL;

/*
	3. In each continent, the highest mountain and its height in meters and in feet.
*/


SELECT DISTINCT ON (continent) encompasses.continent,mountain.name,mountain.height FROM (mountain INNER JOIN geo_mountain ON mountain.name=geo_mountain.mountain INNER JOIN encompasses ON geo_mountain.country=encompasses.country) GROUP BY encompasses.continent,mountain.name,mountain.height ORDER by continent, height DESC;


/*
	4. Show the country name and ratio of border length to number of neighboring countries in descending order.
*/

SELECT name,SUM(borders.length)/COUNT(country2) as ratio FROM country INNER JOIN borders ON country.code=borders.country1 OR country.code=borders.country2 GROUP BY country.name ORDER BY ratio DESC;

/*
	5. Show a list of country name and projected populations in 10, 25,50 and 100 years if current demographic trends continue unabated.
*/

SELECT name,(population*(POWER(1+population_growth/100,10))) as in10yrs,(population*(POWER(1+population_growth/100,25))) as in25yrs,(population*(POWER(1+population_growth/100,50))) as in50yrs,(population*(POWER(1+population_growth/100,100))) as in100yrs FROM country INNER JOIN population ON country.code=population.country GROUP BY name,population,population_growth ORDER BY name DESC;


/*
	6. Names of all non-NATO countries that border a NATO country?
*/

SELECT DISTINCT ON (country) name,organization FROM country INNER JOIN isMember ON country.code=isMember.country INNER JOIN borders ON (country.code=borders.country1 OR country.code=borders.country2) WHERE country.code NOT IN (SELECT isMember.country FROM isMember WHERE organization='NATO' AND type='member') AND (borders.country1 IN (SELECT isMember.country FROM isMember WHERE organization='NATO' AND type='member') OR borders.country2 IN (SELECT isMember.country FROM isMember WHERE organization='NATO' AND type='member'));


/*
	7. Give all countries that can be reached overland from Mexico. Thus Canada is in answer, but Sweden is not. Hint, use recursion.
*/

#My plan: recursively go through the countries next to Mexico, and then countries next to those countries and so on. 

WITH RECURSIVE overlandCountries AS(SELECT borders.country2,borders.country1 FROM borders WHERE borders.country1 in (SELECT country.code FROM country WHERE country.name = 'Mexico') OR borders.country2 in (SELECT country.code FROM country WHERE country.name = 'Mexico') UNION SELECT borders.country1, borders.country2 FROM borders JOIN overlandCountries c ON(borders.country2=c.country1 OR borders.country1=c.country1 OR borders.country1=c.country2 OR borders.country2=c.country2))  SELECT name FROM country WHERE code IN (SELECT country1 FROM overlandCountries UNION ALL SELECT country2 FROM overlandCountries GROUP BY overlandCountries.country2);


/*
	8. Create a view EightThousanders(name,mountains,height,coordinates) which
includes the mountains over or equal to the height of 8000 meters. Query for the countries including EightThousanders. Try to avoid materializing the whole Mountain relation. Verify via EXPLAIN ANALYSE.
*/

CREATE VIEW EightThousanders AS SELECT name,mountains,height,coordinates FROM mountain WHERE height>=8000;
#Query for the countries including EightThousanders. - vad menas?
EXPLAIN ANALYSE SELECT * FROM EightThousanders;



/*
	9. Write rules to enable updates to EightThousanders to be reflected back to Mountain. For example be able to rectify the injustice of Everest being taller than K2!
 UPDATE EightThousanders SET Height = 8610 WHERE name=’Mount Everest’;
 */

 CREATE OR REPLACE RULE "UPDATE_MOUNTAIN" AS ON UPDATE TO EightThousanders DO ALSO UPDATE mountain SET mountains=NEW.mountains, height=NEW.height,coordinates=NEW.coordinates WHERE name=NEW.name;














