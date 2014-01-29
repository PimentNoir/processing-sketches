package shapes3d;

public interface SConstants {
	int WIRE = 		0x00000011;
	int SOLID = 	0x00000012;
	int TEXTURE = 	0x00000014;
	int DRAWALL = WIRE | SOLID | TEXTURE;
	
	// Constants for Cone shapes
	int BASE =	0x02000001;
	int CONE = 	0x02000002;
	int ALL = BASE | CONE;

	// Constants for BezTube, Tube & Helix shapes
	int E_CAP =	0x03000001;
	int S_CAP = 	0x03000002;
	int BOTH_CAP = E_CAP | S_CAP;


	int WHITE = -1;
	int BLACK = -16777216;
	int GREY = -4144960;

}
