from pinotdb import connect
from openai import OpenAI

model = 'text-embedding-ada-002'
search = input("what do you want to eat? ")

client = OpenAI()

def get_embedding(text, model=model):
   text = text.replace("\n", " ")
   return client.embeddings.create(input = [text], model=model).data[0].embedding

search_embedding = get_embedding(search)

conn = connect(host='localhost', port=8000, path='/query/sql', scheme='http')
curs = conn.cursor()
curs.execute(f"""
with DIST as (
  SELECT 
    ProductId, 
    Summary, 
    Score,
    l2_distance(embedding, ARRAY{search_embedding}) AS l2_dist
  from fineFoodReviews
)
select * from DIST
where l2_dist < .6
order by l2_dist asc
""", queryOptions="useMultistageEngine=true")
for row in curs:
    print(row)

curs2 = conn.cursor()
sql = f"""
SELECT 
  ProductId, 
  Summary, 
  Score,
  l2_distance(embedding, ARRAY{search_embedding}) AS l2_dist
from fineFoodReviews
where VECTOR_SIMILARITY(embedding, ARRAY{search_embedding}, 5)
order by l2_dist asc
"""
curs2.execute(sql)

for row in curs2:
    print(row)

