import javax.swing.JPanel;
import javax.swing.JTextField;

import net.miginfocom.swing.MigLayout;


public class Quake
{
	static final int START_MONTH = 6;
	static final int END_MONTH = 18;
	static final int SEVERITY = 1;
	
	int startMonth = START_MONTH;
	int endMonth = END_MONTH;
	int severity = SEVERITY;

	JPanel quakePanel = new JPanel(new MigLayout("insets 1"));
	
	JTextField startMonthTF = new JTextField(Integer.toString(startMonth), 2);
	JTextField endMonthTF = new JTextField(Integer.toString(endMonth), 2);
	JTextField severityTF = new JTextField(Integer.toString(severity), 2);
}
