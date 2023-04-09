import shutil
import os
import untangle

obj = untangle.parse('droptableuser-love.xml')

result = []
for o in obj.plist.dict.dict.dict:
	result.append(o.string[6].cdata)

print(len(result)) 

for idx, r in enumerate(result):
	try:
		shutil.copyfile(r[7:], "loved/" + os.path.basename(r))
		print(idx)
	except Exception as e:
		print(e)





