/*  
 *  Copyright(C) 2014, Jérôme Benoit <jerome.benoit@piment-noir.org> under GPLv3 
 *  Debug.pde
 *  A very basic debug facility for processing
 *  Usage : Create a debug class inside your sketch and you will 
 *  have string printing and printing once functionnality inside 
 *  the main processing draw() loop conditional to a boolean.
 *  Hook properly the last call to prtStr and prStrOnce methods inside the draw() loop.   
 */

public static final class Debug {
  private static int printCount = 0;
  private static boolean enableDebug = false;

  public Debug(boolean enableDebug) {
    Debug.enableDebug = enableDebug;
  }

  public static void DonePrinting() {
    printCount = 1;
  }

  public static void UndoPrinting() {
    if (enableDebug) { 
      printCount = 0;
    }
  }

  public static void prStr(String string) {
    if (enableDebug) { 
      println(string);
    }
  }

  public static void prStrOnce(String string) {
    if (printCount == 0 && enableDebug) { 
      println(string);
    }
  }
}