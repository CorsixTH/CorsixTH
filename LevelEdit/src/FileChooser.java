import java.io.File;
import java.io.IOException;

import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JOptionPane;
import javax.swing.filechooser.FileNameExtensionFilter;

//creates JFileChooser
public class FileChooser extends JFileChooser
{
	//this is insignificant but apparently its needed because JFrame is serializable
	private static final long serialVersionUID = 1L;
	ReaderWriter readerWriter = new ReaderWriter();
	
	FileNameExtensionFilter corsixTH = new FileNameExtensionFilter(
			"CorsixTH level files (.level)", "level");
//	FileNameExtensionFilter originalTH = new FileNameExtensionFilter(
//			"Theme Hospital Level files (.SAM)", "SAM");
	FileNameExtensionFilter anyLevel = new FileNameExtensionFilter(
			"All Level files (.level/.SAM)", "level", "SAM");
	
public FileChooser()
{
	setFileFilter(corsixTH);
	setAcceptAllFileFilterUsed(false);
	setCurrentDirectory(readerWriter.getLastFilePath());
}

	public File open()
	{
		addChoosableFileFilter(anyLevel);
		int returnVal = showOpenDialog(null);
		if (returnVal == JFileChooser.APPROVE_OPTION)
		{
			readerWriter.saveLastFilePath(getSelectedFile().getPath());
			return getSelectedFile();
		} else
		{
			return null;
		}
	}
	public File saveAs() throws IOException
	{
		removeChoosableFileFilter(anyLevel);
		int returnVal = showSaveDialog(null);
		if (returnVal == JFileChooser.APPROVE_OPTION)
		{
			File file = getSelectedFile();
			readerWriter.saveLastFilePath(file.getPath());
			
			if (file.exists())
			{
				//confirm to overwrite file
				JOptionPane overwrite = new JOptionPane("Overwrite file?");
				Object[] options = new String[] {"Yes", "No" };
				overwrite.setOptions(options);

				JDialog dialog = overwrite.createDialog(null, "Confirm");
				dialog.setVisible(true);
				
				if ((overwrite.getValue()) == options[0])
					return (getSelectedFile());
				else
					return null;
				
			}
			else
			{
				// if no file extension is given, append one.
				if (! file.getPath().endsWith(".level"))
				{
					file = new File(file.getPath() + ".level");
				}
				return file;
			}
		} else
		{
			return null;
		}
	}
}
