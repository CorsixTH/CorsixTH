import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.IOException;

import javax.swing.JDialog;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;

//creates FileChooser, MenuItems, JMenu
public class Menu extends JMenuBar
{

	//this is insignificant but apparently its needed because JFrame is serializable
	private static final long serialVersionUID = 1L;

	ReaderWriter readerWriter = new ReaderWriter();
	VarManipulator var = new VarManipulator();
	FileChooser fileChooser = new FileChooser();

	JMenuItem fileNew = new JMenuItem("New");
	JMenuItem fileOpen = new JMenuItem("Open");
//	JMenuItem fileSave = new JMenuItem("Save");
	JMenuItem fileSaveAs = new JMenuItem("Save As");
	
	JMenuItem about = new JMenuItem("About");
	
	


	public Menu()
	{
		JMenu menuFile = new JMenu("File");
		menuFile.add(fileNew);
		menuFile.add(fileOpen);
//		menuFile.add(fileSave);
		menuFile.add(fileSaveAs);
		
		JMenu menuHelp = new JMenu("Help");
		menuHelp.add(about);

		add(menuFile);
		add(menuHelp);

		// new
		fileNew.addActionListener(new ActionListener()
		{
			public void actionPerformed(ActionEvent e)
			{
				var.setDefault();
				var.setAllDiseasesAvailable();
			}
		});

		// open
		fileOpen.addActionListener(new ActionListener()
		{
			public void actionPerformed(ActionEvent e)
			{
				
				File file = (fileChooser.open());
				if (file != null)
				{
					//set all variables to default first in case some values are missing inside the file.
					var.setDefault();
//					String extension = file.getName().substring(file.getName().lastIndexOf("."));
//					if (extension.toLowerCase().matches("sam"))
//							readerWriter.open(new File ("original.level"));
					
					readerWriter.open(file);
				}
			}
		}); 

		// save as
		fileSaveAs.addActionListener(new ActionListener()
		{
			public void actionPerformed(ActionEvent e)
			{
				try
				{
				File file = (fileChooser.saveAs());
				if (file != null)
					readerWriter.saveAs(file);
				}catch (IOException e1)
				{
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
			}
		});
		
		about.addActionListener(new ActionListener()
		{
			public void actionPerformed(ActionEvent e)
			{
				JOptionPane aboutPane = new JOptionPane("Version: " + Main.VERSION +"\n\n" +
								"Programmers: snowblind\n" +
								"Logo Artist: Wolter\n\n" + 
								"Software includes MigLayout library. (www.miglayout.com)");
				Object[] options = new String[] {"Ok" };
				aboutPane.setOptions(options);

				JDialog dialog = aboutPane.createDialog(null, "About");
				dialog.setVisible(true);
			}
		});
	}
}
