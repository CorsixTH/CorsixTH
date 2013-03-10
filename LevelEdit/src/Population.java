import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

import net.miginfocom.swing.MigLayout;


public class Population
{
	static final int MONTH = 0;
	static final int SPAWN = 0;
	static final int CHANGE = 1;
	
	int month = MONTH;
	int spawn = SPAWN;
	int change = CHANGE;
	
	
	JPanel populationPanel = new JPanel(new MigLayout("insets 1"));
	
	JTextField monthTF = new JTextField(Integer.toString(month), 2);
	JTextField changeTF = new JTextField(Integer.toString(change), 2);
	JLabel spawnLabel = new JLabel("Number of patients: " + spawn);
	JLabel changeLabel = new JLabel("Change per month:");
	JLabel monthLabel = new JLabel("Month:");
}
