import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;

public class Main
{	
	static final double VERSION = 0.14;
	public static void main(String[] args)
	{
		try
		{
        // Set System L&F
        UIManager.setLookAndFeel(
            UIManager.getSystemLookAndFeelClassName());
	    }
		catch (UnsupportedLookAndFeelException e)
	    {
	       // handle exception
	    }
		catch (ClassNotFoundException e)
		{
	       // handle exception
	    }
	    catch (InstantiationException e)
	    {
	       // handle exception
	    }
	    catch (IllegalAccessException e)
	    {
	       // handle exception
	    }
		Gui gui = new Gui();
		gui.setVisible(true);

		VarManipulator variableManipulator = new VarManipulator();
		variableManipulator.setDefault();
		variableManipulator.setAllDiseasesAvailable();
	}
}

/* TODO known issues
 * file can be saved without any file extension
 * on exit > save > cancel, the program should not close.
 * 
 * TODO improvements
 * TabEmergencies: it should not be possible to choose non-existant diseases
 * TabDiseases: if disease is set to non-existant, set the other fields to uneditable.
 * textfields: option to reset to default individually
 * give warning when there is no way a disease can be cured.
 * should only ask for saving changes on exit if changes have been made.
 * show current file on the window title
 * save function (not save as)
 * save documentation to file?
 * error handling
 * multilingual support (priority: disease names)
 * 
 * TODO testing
 * compatibility with sam files
 * 		why do the sam files have values other than 0 or 1 for
 * 		#visuals / #non_visuals? does it affect the frequency of each disease?
 * 		is it implemented in CTH yet?
 * TabStaff: do the staff distribution entries have to be chronological?
 * 
 */