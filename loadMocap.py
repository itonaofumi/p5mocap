# mocap関節の位置データをロケーターに流す
import maya.cmds as cmds

posFilePath = r"F:\Documents\SelfStudy\processing\mocap\positions.txt"
fo = file(posFilePath , "r")
lines = fo.readlines()
fo.close()

# create locators
'''
cmds.spaceLocator(name="HEAD")
cmds.spaceLocator(name="NECK")
cmds.spaceLocator(name="TORSO")
cmds.spaceLocator(name="HIP")
cmds.spaceLocator(name="LEFT_SHOULDER")
cmds.spaceLocator(name="LEFT_ELBOW")
cmds.spaceLocator(name="LEFT_ELBOW_UPV")
cmds.spaceLocator(name="LEFT_HAND")
cmds.spaceLocator(name="RIGHT_SHOULDER")
cmds.spaceLocator(name="RIGHT_ELBOW")
cmds.spaceLocator(name="RIGHT_ELBOW_UPV")
cmds.spaceLocator(name="RIGHT_HAND")
cmds.spaceLocator(name="LEFT_HIP")
cmds.spaceLocator(name="LEFT_KNEE")
cmds.spaceLocator(name="LEFT_KNEE_UPV")
cmds.spaceLocator(name="LEFT_FOOT")
cmds.spaceLocator(name="RIGHT_HIP")
cmds.spaceLocator(name="RIGHT_KNEE")
cmds.spaceLocator(name="RIGHT_KNEE_UPV")
cmds.spaceLocator(name="RIGHT_FOOT")
'''
# select locators
cmds.select('HEAD', r=True)
cmds.select('NECK', add=True)
cmds.select('TORSO', add=True)
cmds.select('RIGHT_SHOULDER', add=True)
cmds.select('RIGHT_ELBOW', add=True)
cmds.select('RIGHT_HAND', add=True)
cmds.select('LEFT_SHOULDER', add=True)
cmds.select('LEFT_ELBOW', add=True)
cmds.select('LEFT_HAND', add=True)
cmds.select('RIGHT_HIP', add=True)
cmds.select('RIGHT_KNEE', add=True)
cmds.select('RIGHT_FOOT', add=True)
cmds.select('LEFT_HIP', add=True)
cmds.select('LEFT_KNEE', add=True)
cmds.select('LEFT_FOOT', add=True)

selectedItems = cmds.ls(sl=1, long=1)
setFrame = 0

# １行ずつ取り出して処理を開始
for line in lines:
    #print(line)
    
    # いらないカッコとスペースと改行を削除
    line = line.replace("[", "")
    line = line.replace("]", "")
    line = line.replace(" ", "")
    line = line.rstrip("\r\n")
    #print(line)
    
    # カンマで分割
    line = line.split(",")
    #print(line)
    
    # 3つずつ取り出してmocapリストに突っ込む
    tmp = []
    mocap = []
    count = 0;
    for value in line:
        tmp.append(value)
        count += 1
        if count == 3:
            mocap.append(tmp)
            tmp = []
            count = 0
    #print(mocap)

    for i, selectedItem in enumerate(selectedItems):
        cmds.setKeyframe( "%s.translateX" % selectedItem, time=(setFrame,setFrame), value=float(mocap[i][0])*0.1)
        cmds.setKeyframe( "%s.translateY" % selectedItem, time=(setFrame,setFrame), value=float(mocap[i][2])*0.1)
        cmds.setKeyframe( "%s.translateZ" % selectedItem, time=(setFrame,setFrame), value=float(mocap[i][1])*0.1)

    setFrame += 1