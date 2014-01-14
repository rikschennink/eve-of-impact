//
//  ParallaxLayer.m
//  Eve of Impact
//
//  Created by Rik Schennink on 4/12/10.
//  Copyright 2011 Rik Schennink. All rights reserved.
//

#import "ParallaxLayer.h"
#import "RenderEngine.h"
#import "Prefs.h"
#import "Camera.h"
#import "ApplicationModel.h"

@implementation ParallaxLayer

static const int smallStarCoordinates[240] = {-371,-1299,-1523,1132,-676,-1543,-622,-1144,-1467,737,-92,-1588,-268,-1282,-1571,-69,347,-1552,-893,1012,-1428,1472,184,-1478,-506,-333,-1460,273,296,-1404,-522,-240,-1540,76,-1165,-1510,536,777,-1521,1092,-661,-1541,825,-702,-1569,465,135,-1571,-772,-1281,-1547,-498,118,-1453,779,276,-1577,-767,1013,-1474,-1181,-851,-1565,467,1388,-1435,1157,1464,-1517,-30,-750,-1421,784,1341,-1573,19,-1268,-1449,1064,1116,-1568,-1300,-377,-1504,-380,568,-1411,140,213,-1410,299,584,-1410,417,-822,-1446,-687,951,-1426,1229,-914,-1535,1449,-80,-1568,-1221,-415,-1505,-991,530,-1542,1392,-151,-1574,-740,720,-1519,-1077,-813,-1546,-830,267,-1549,-1394,1250,-1532,686,-455,-1497,-573,-864,-1572,-415,-1403,-1432,-932,-843,-1405,1249,1070,-1550,-1020,1135,-1447,17,-1215,-1548,44,-374,-1588,-808,1264,-1503,-1281,-689,-1513,-577,-120,-1579,222,927,-1402,-344,489,-1430,898,-270,-1423,107,481,-1540,-210,1365,-1548,-934,-227,-1409,412,-1312,-1515,186,1217,-1469,773,298,-1457,1321,1390,-1574,-1363,-74,-1499,-873,18,-1485,-874,-355,-1539,-1210,251,-1512,-1310,-1286,-1598,-370,-1256,-1589,-1495,506,-1549,1384,816,-1425,1024,871,-1591,-55,1324,-1418,286,-84,-1519,6,-134,-1481,768,-119,-1560,-39,-671,-1464,915,-1461,-1477,477,-413,-1477,-1387,469,-1530};
static const int mediumStarCoordinates[90] = {843,125,-1107,-711,-74,-1045,-598,-115,-1083,-943,-321,-1187,-101,-727,-1174,460,-862,-1190,889,-497,-1031,-359,-596,-1094,-297,531,-1130,79,-294,-1199,987,207,-1181,545,496,-1135,533,-263,-1147,320,-578,-1180,303,440,-1060,687,981,-1014,-172,-804,-1003,-49,739,-1014,878,364,-1153,-532,541,-1125,-322,651,-1070,-735,-85,-1133,-107,224,-1018,-105,-75,-1033,480,900,-1059,412,628,-1108,902,-91,-1194,-76,-930,-1174,264,339,-1033,-294,990,-1161};
static const int largeStarCoordinates[15] = {-280,-250,-950,-120,450,-850,230,-400,-950,160,-90,-870,-210,290,-950};


-(id)initWithModel:(ApplicationModel*)applicationModel {
	
	self = [super init];
	
	if (self) {
		
		model = applicationModel;
		
		scale = IS_IPAD ? 2.0 : 1.0;
		
		VertexBuffer stars = VertexBufferMake();
		
		[[RenderEngine singleton] addVertexBuffer:stars at:VBO_STATIC_SPACE];
		[[RenderEngine singleton] setActiveVertexBuffer:VBO_STATIC_SPACE];
		
		QuadTemplate nebula = QuadTemplateMake(400.0 * scale, 
											   0, 
											   -2000.0, 
											   2048.0 * scale, 4096.0 * scale, 
											   ColorMakeFast(), 
											   UVMapMake(640, 0, 380, 780));
		[[RenderEngine singleton] addQuad:&nebula andRotateBy:10.0];
		
		uint count = 0;
		uint i = 0;
        float size = 0;
		QuadTemplate star;
		
		for (i = 0; i < 80; i++) {
			
			star = QuadTemplateMake(
										smallStarCoordinates[i*3] * scale, 
										smallStarCoordinates[(i*3)+1] * scale, 
										smallStarCoordinates[(i*3)+2], 
										4.0 * scale, 4.0 * scale,
										ColorMakeByOpacity(count%2==0 ? .5 : 1.0), 
										UVMapMake(2, 442, 4, 4));
			
			[[RenderEngine singleton] addQuad:&star];
			
			count++;
		}
		
		for (i = 0; i < 30; i++) {
			
			star = QuadTemplateMake(
										mediumStarCoordinates[i*3] * scale, 
										mediumStarCoordinates[(i*3)+1] * scale, 
										mediumStarCoordinates[(i*3)+2], 
										9.0 * scale, 9.0 * scale, 
										ColorMakeFast(), 
										UVMapMake(2, 433, 6, 6));
			
			[[RenderEngine singleton] addQuad:&star];
			
		}
		
		for (i = 0; i < 5; i++) {
			
            size = (40 + i * 5) * scale;
            
			star = QuadTemplateMake(
										largeStarCoordinates[i*3] * scale, 
										largeStarCoordinates[(i*3)+1] * scale, 
										largeStarCoordinates[(i*3)+2], 
										size, size, 
										ColorMakeFast(), 
                                        UVMapMake(360, 432, 56, 56));
			
			[[RenderEngine singleton] addQuad:&star];
			
		}
	}
	
	return self;
}

/*

 x -
 y |
 z .
 
*/

-(void)redraw:(float)interpolation {
	
	// set space vertex buffer
	[[RenderEngine singleton] setActiveVertexBuffer:VBO_STATIC_SPACE];
	
	// add camera transforms to this buffer
	Vector cameraOffset = [[RenderEngine singleton] getCameraOffset];
	
	Transform cameraTranslation = TransformMake(TRANSFORM_TRANSLATE, 0.0, Transform3DMake(cameraOffset.x * .5,cameraOffset.y * .5,0.0));
	Transform cameraRotationX = TransformMake(TRANSFORM_ROTATE, (cameraOffset.y / scale) * .035, Transform3DMake(1.0,0.0,0.0));
	Transform cameraRotationY = TransformMake(TRANSFORM_ROTATE, (cameraOffset.x / scale) * -.05, Transform3DMake(0.0,1.0,0.0));
	Transform cameraRotationZ = TransformMake(TRANSFORM_ROTATE, model.camera.rotation * 1.5, Transform3DMake(0.0,0.0,1.0));
	[[RenderEngine singleton] addTransformToActiveVertexBuffer:cameraTranslation];
	[[RenderEngine singleton] addTransformToActiveVertexBuffer:cameraRotationX];
	[[RenderEngine singleton] addTransformToActiveVertexBuffer:cameraRotationY];
	[[RenderEngine singleton] addTransformToActiveVertexBuffer:cameraRotationZ];
	
	// render the buffer
	[[RenderEngine singleton] renderActiveVertexBuffer];
	
	// reset transforms
	[[RenderEngine singleton] resetTransformsOfActiveVertexBuffer];
	
}

@end
