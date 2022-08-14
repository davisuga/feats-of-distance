time java -jar cypher-shell.jar -p "SlZ6b85XMAqbnpkIlOOCgzQS5SSBHrWgGSCur-u99nM" -a=neo4j+s://80878a09.databases.neo4j.io -u=neo4j "MERGE (spotifyartist0A7g2YbCA9FlyZvAG6VmKP:Author {uri: 'spotify:artist:0A7g2YbCA9FlyZvAG6VmKP'}) set spotifyartist0A7g2YbCA9FlyZvAG6VmKP.name = \"The LOX\"
MERGE (spotifyartist0ABk515kENDyATUdpCKVfW:Author {uri: 'spotify:artist:0ABk515kENDyATUdpCKVfW'}) set spotifyartist0ABk515kENDyATUdpCKVfW.name = \"Westside Gunn\"
MERGE (spotifyartist0DYOJB7f913SAUhPolsY0d:Author {uri: 'spotify:artist:0DYOJB7f913SAUhPolsY0d'}) set spotifyartist0DYOJB7f913SAUhPolsY0d.name = \"Exodus Simmons\"
MERGE (spotifyartist0m2Wc2gfNUWaAuBK7URPIJ:Author {uri: 'spotify:artist:0m2Wc2gfNUWaAuBK7URPIJ'}) set spotifyartist0m2Wc2gfNUWaAuBK7URPIJ.name = \"Bono\"
MERGE (spotifyartist1HwM5zlC5qNWhJtM00yXzG:Author {uri: 'spotify:artist:1HwM5zlC5qNWhJtM00yXzG'}) set spotifyartist1HwM5zlC5qNWhJtM00yXzG.name = \"DMX\"
MERGE (spotifyartist20qISvAhX20dpIbOOzGK3q:Author {uri: 'spotify:artist:20qISvAhX20dpIbOOzGK3q'}) set spotifyartist20qISvAhX20dpIbOOzGK3q.name = \"Nas\"
MERGE (spotifyartist23zg3TcAtWQy7J6upgbUnj:Author {uri: 'spotify:artist:23zg3TcAtWQy7J6upgbUnj'}) set spotifyartist23zg3TcAtWQy7J6upgbUnj.name = \"Usher\"
MERGE (spotifyartist2cADQgiLMjNhbsfeN52Bf3:Author {uri: 'spotify:artist:2cADQgiLMjNhbsfeN52Bf3'}) set spotifyartist2cADQgiLMjNhbsfeN52Bf3.name = \"Swizz Beatz\"
MERGE (spotifyartist3AEGa5t5Hi77Hrg8EMuT84:Author {uri: 'spotify:artist:3AEGa5t5Hi77Hrg8EMuT84'}) set spotifyartist3AEGa5t5Hi77Hrg8EMuT84.name = \"Brian King Joseph\"
MERGE (spotifyartist3DiDSECUqqY1AuBP8qtaIa:Author {uri: 'spotify:artist:3DiDSECUqqY1AuBP8qtaIa'}) set spotifyartist3DiDSECUqqY1AuBP8qtaIa.name = \"Alicia Keys\"
MERGE (spotifyartist4NhyK1Uoo8ScQOSl8x0jqI:Author {uri: 'spotify:artist:4NhyK1Uoo8ScQOSl8x0jqI'}) set spotifyartist4NhyK1Uoo8ScQOSl8x0jqI.name = \"Denaun\"
MERGE (spotifyartist55Aa2cqylxrFIXC767Z865:Author {uri: 'spotify:artist:55Aa2cqylxrFIXC767Z865'}) set spotifyartist55Aa2cqylxrFIXC767Z865.name = \"Lil Wayne\"
MERGE (spotifyartist5Matrg5du62bXwer29cU5T:Author {uri: 'spotify:artist:5Matrg5du62bXwer29cU5T'}) set spotifyartist5Matrg5du62bXwer29cU5T.name = \"Benny The Butcher\"
MERGE (spotifyartist67gqUXxHedeUGDTxwBzdjS:Author {uri: 'spotify:artist:67gqUXxHedeUGDTxwBzdjS'}) set spotifyartist67gqUXxHedeUGDTxwBzdjS.name = \"Conway the Machine\"
MERGE (spotifyartist7hJcb9fa4alzcOq3EaNPoG:Author {uri: 'spotify:artist:7hJcb9fa4alzcOq3EaNPoG'}) set spotifyartist7hJcb9fa4alzcOq3EaNPoG.name = \"Snoop Dogg\"
MERGE (spotifyartist0A7g2YbCA9FlyZvAG6VmKP)-[:FEATS_WITH {name:\"That's My Dog (feat. The LOX & Swizz Beatz) - Acapella\", uri:'spotify:track:75rL5t1jI194pgC7nt3oXG'}]->(spotifyartist2cADQgiLMjNhbsfeN52Bf3)
MERGE (spotifyartist0ABk515kENDyATUdpCKVfW)-[:FEATS_WITH {name:\"Hood Blues (feat. Westside Gunn, Benny The Butcher & Conway The Machine) - Acapella\", uri:'spotify:track:4hgLCh56N154sGYCxNmc54'}]->(spotifyartist5Matrg5du62bXwer29cU5T)
MERGE (spotifyartist0ABk515kENDyATUdpCKVfW)-[:FEATS_WITH {name:\"Hood Blues (feat. Westside Gunn, Benny The Butcher & Conway The Machine) - Acapella\", uri:'spotify:track:4hgLCh56N154sGYCxNmc54'}]->(spotifyartist67gqUXxHedeUGDTxwBzdjS)
MERGE (spotifyartist0DYOJB7f913SAUhPolsY0d)-[:FEATS_WITH {name:\"Walking In The Rain (feat. Nas, Exodus Simmons & Denaun) - Acapella\", uri:'spotify:track:1KX2MqD0ijZ8pQHHnIDGyS'}]->(spotifyartist4NhyK1Uoo8ScQOSl8x0jqI)
MERGE (spotifyartist1HwM5zlC5qNWhJtM00yXzG)-[:FEATS_WITH {name:\"Dogs Out (feat. Lil Wayne & Swizz Beatz) - Acapella\", uri:'spotify:track:1f1VYSQkg16DW7TKYLtVq7'}]->(spotifyartist2cADQgiLMjNhbsfeN52Bf3)
MERGE (spotifyartist1HwM5zlC5qNWhJtM00yXzG)-[:FEATS_WITH {name:\"Dogs Out (feat. Lil Wayne & Swizz Beatz) - Acapella\", uri:'spotify:track:1f1VYSQkg16DW7TKYLtVq7'}]->(spotifyartist55Aa2cqylxrFIXC767Z865)
MERGE (spotifyartist1HwM5zlC5qNWhJtM00yXzG)-[:FEATS_WITH {name:\"Hold Me Down (feat. Alicia Keys) - Acapella\", uri:'spotify:track:3SRhvCC2xQqiB61XhrLLL0'}]->(spotifyartist3DiDSECUqqY1AuBP8qtaIa)
MERGE (spotifyartist1HwM5zlC5qNWhJtM00yXzG)-[:FEATS_WITH {name:\"Hood Blues (feat. Westside Gunn, Benny The Butcher & Conway The Machine) - Acapella\", uri:'spotify:track:4hgLCh56N154sGYCxNmc54'}]->(spotifyartist0ABk515kENDyATUdpCKVfW)
MERGE (spotifyartist1HwM5zlC5qNWhJtM00yXzG)-[:FEATS_WITH {name:\"Hood Blues (feat. Westside Gunn, Benny The Butcher & Conway The Machine) - Acapella\", uri:'spotify:track:4hgLCh56N154sGYCxNmc54'}]->(spotifyartist5Matrg5du62bXwer29cU5T)
MERGE (spotifyartist1HwM5zlC5qNWhJtM00yXzG)-[:FEATS_WITH {name:\"Hood Blues (feat. Westside Gunn, Benny The Butcher & Conway The Machine) - Acapella\", uri:'spotify:track:4hgLCh56N154sGYCxNmc54'}]->(spotifyartist67gqUXxHedeUGDTxwBzdjS)
MERGE (spotifyartist1HwM5zlC5qNWhJtM00yXzG)-[:FEATS_WITH {name:\"Letter To My Son (Call Your Father) (feat. Usher & Brian King Joseph) - Acapella\", uri:'spotify:track:1YfWDe7HipQtmv4ozAC4ao'}]->(spotifyartist23zg3TcAtWQy7J6upgbUnj)
MERGE (spotifyartist1HwM5zlC5qNWhJtM00yXzG)-[:FEATS_WITH {name:\"Letter To My Son (Call Your Father) (feat. Usher & Brian King Joseph) - Acapella\", uri:'spotify:track:1YfWDe7HipQtmv4ozAC4ao'}]->(spotifyartist3AEGa5t5Hi77Hrg8EMuT84)
MERGE (spotifyartist1HwM5zlC5qNWhJtM00yXzG)-[:FEATS_WITH {name:\"Skyscrapers (feat. Bono) - Acapella\", uri:'spotify:track:0ZZd4d0M92XXOo7klE8yWb'}]->(spotifyartist0m2Wc2gfNUWaAuBK7URPIJ)
MERGE (spotifyartist1HwM5zlC5qNWhJtM00yXzG)-[:FEATS_WITH {name:\"Take Control (feat. Snoop Dogg) - Acapella\", uri:'spotify:track:6c6TRahXyWqmdIVh3KP6Cu'}]->(spotifyartist7hJcb9fa4alzcOq3EaNPoG)
MERGE (spotifyartist1HwM5zlC5qNWhJtM00yXzG)-[:FEATS_WITH {name:\"That's My Dog (feat. The LOX & Swizz Beatz) - Acapella\", uri:'spotify:track:75rL5t1jI194pgC7nt3oXG'}]->(spotifyartist0A7g2YbCA9FlyZvAG6VmKP)
MERGE (spotifyartist1HwM5zlC5qNWhJtM00yXzG)-[:FEATS_WITH {name:\"That's My Dog (feat. The LOX & Swizz Beatz) - Acapella\", uri:'spotify:track:75rL5t1jI194pgC7nt3oXG'}]->(spotifyartist2cADQgiLMjNhbsfeN52Bf3)
MERGE (spotifyartist1HwM5zlC5qNWhJtM00yXzG)-[:FEATS_WITH {name:\"Walking In The Rain (feat. Nas, Exodus Simmons & Denaun) - Acapella\", uri:'spotify:track:1KX2MqD0ijZ8pQHHnIDGyS'}]->(spotifyartist0DYOJB7f913SAUhPolsY0d)
MERGE (spotifyartist1HwM5zlC5qNWhJtM00yXzG)-[:FEATS_WITH {name:\"Walking In The Rain (feat. Nas, Exodus Simmons & Denaun) - Acapella\", uri:'spotify:track:1KX2MqD0ijZ8pQHHnIDGyS'}]->(spotifyartist20qISvAhX20dpIbOOzGK3q)
MERGE (spotifyartist1HwM5zlC5qNWhJtM00yXzG)-[:FEATS_WITH {name:\"Walking In The Rain (feat. Nas, Exodus Simmons & Denaun) - Acapella\", uri:'spotify:track:1KX2MqD0ijZ8pQHHnIDGyS'}]->(spotifyartist4NhyK1Uoo8ScQOSl8x0jqI)
MERGE (spotifyartist20qISvAhX20dpIbOOzGK3q)-[:FEATS_WITH {name:\"Walking In The Rain (feat. Nas, Exodus Simmons & Denaun) - Acapella\", uri:'spotify:track:1KX2MqD0ijZ8pQHHnIDGyS'}]->(spotifyartist0DYOJB7f913SAUhPolsY0d)
MERGE (spotifyartist20qISvAhX20dpIbOOzGK3q)-[:FEATS_WITH {name:\"Walking In The Rain (feat. Nas, Exodus Simmons & Denaun) - Acapella\", uri:'spotify:track:1KX2MqD0ijZ8pQHHnIDGyS'}]->(spotifyartist4NhyK1Uoo8ScQOSl8x0jqI)
MERGE (spotifyartist23zg3TcAtWQy7J6upgbUnj)-[:FEATS_WITH {name:\"Letter To My Son (Call Your Father) (feat. Usher & Brian King Joseph) - Acapella\", uri:'spotify:track:1YfWDe7HipQtmv4ozAC4ao'}]->(spotifyartist3AEGa5t5Hi77Hrg8EMuT84)
MERGE (spotifyartist55Aa2cqylxrFIXC767Z865)-[:FEATS_WITH {name:\"Dogs Out (feat. Lil Wayne & Swizz Beatz) - Acapella\", uri:'spotify:track:1f1VYSQkg16DW7TKYLtVq7'}]->(spotifyartist2cADQgiLMjNhbsfeN52Bf3)
MERGE (spotifyartist5Matrg5du62bXwer29cU5T)-[:FEATS_WITH {name:\"Hood Blues (feat. Westside Gunn, Benny The Butcher & Conway The Machine) - Acapella\", uri:'spotify:track:4hgLCh56N154sGYCxNmc54'}]->(spotifyartist67gqUXxHedeUGDTxwBzdjS)" --format plain
