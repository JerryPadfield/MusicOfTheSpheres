uniform float time;


void main()
{
	//on prend 3 coordonnées de textures que l'on fait évolué en fonction du temps
	//(comme un affiche publicitaire déroulante)
	gl_TexCoord[0].x = gl_MultiTexCoord0.x+time;
	gl_TexCoord[0].y= gl_MultiTexCoord0.y;
	gl_TexCoord[1].x = gl_MultiTexCoord0.x;
	gl_TexCoord[1].y= gl_MultiTexCoord0.y+time;
	gl_TexCoord[2].x = gl_MultiTexCoord0.x-time;
	gl_TexCoord[2].y= gl_MultiTexCoord0.y-time;
	
	//application des transformations usuelles d'espaces
	gl_Position = ftransform();;
} 
