import java.awt.Image;
import java.awt.Toolkit;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JOptionPane;

//create menu and tabBar, set window size, location and on-exit-behaviour.
public class Gui extends JFrame
{
	//this is insignificant but apparently its needed because JFrame is serializable
	private static final long serialVersionUID = 1L;

	//this string is changed on every focusGained event.
	static String tempValue = "";
	
	ReaderWriter readerWriter = new ReaderWriter();
	FileChooser fileChooser = new FileChooser();

	
	public Gui()
	{
		List<Image> icons = new ArrayList<Image>();
		icons.add(Toolkit.getDefaultToolkit().getImage(ClassLoader.getSystemResource("icon256.png")));
		icons.add(Toolkit.getDefaultToolkit().getImage(ClassLoader.getSystemResource("icon128.png")));
		icons.add(Toolkit.getDefaultToolkit().getImage(ClassLoader.getSystemResource("icon64.png")));
		icons.add(Toolkit.getDefaultToolkit().getImage(ClassLoader.getSystemResource("icon48.png")));
		icons.add(Toolkit.getDefaultToolkit().getImage(ClassLoader.getSystemResource("icon32.png")));
		icons.add(Toolkit.getDefaultToolkit().getImage(ClassLoader.getSystemResource("icon24.png")));
		icons.add(Toolkit.getDefaultToolkit().getImage(ClassLoader.getSystemResource("icon16.png")));
		setIconImages(icons);
		
		setTitle("CorsixTH Level Editor");
		
		setSize(800,600);
		setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
		addWindowListener(new WindowAdapter(){
			public void windowClosing(WindowEvent event)
			{
				onExit();
			}
		});
		
		//set location to center
		setLocationRelativeTo(null);
		
		Menu menu = new Menu();
		setJMenuBar(menu);
		
		TabBar tabBar = new TabBar();
		setContentPane(tabBar.tabs);
	}

	protected void onExit()
	{
		JOptionPane exit = new JOptionPane("Save file?");
		Object[] options = new String[] {"Save", "Don't save", "Cancel" };
		exit.setOptions(options);

		JDialog exitDialog = exit.createDialog(this, "Exit");
		exitDialog.setVisible(true);
		
		if (exit.getValue() == options[0])
		{
			try
			{
				File file = (fileChooser.saveAs());
				if (file != null)
				{
					readerWriter.saveAs(file);
					System.exit(0);
				}
			} catch (IOException e)
			{
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		else if (exit.getValue() == options[1])
		{
			System.exit(0);
		}
		else;
		
	}
	
}
