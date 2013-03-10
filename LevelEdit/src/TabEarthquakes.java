import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;
import java.util.ArrayList;

import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextField;

import net.miginfocom.swing.MigLayout;


public class TabEarthquakes
{
	
//variables
	static ArrayList<Quake> quakeList = new ArrayList<Quake>();

//components
	static JPanel earthquakes = new JPanel(new MigLayout());
	JScrollPane scrollPane = new JScrollPane(earthquakes);
	
	JPanel buttonsPanel = new JPanel();
	JButton addButt = new JButton("Add");
	JButton removeButt = new JButton("Remove");
	
	static JLabel randomQuakesLabel = new JLabel("Random earthquakes are enabled.");
	
	public TabEarthquakes()
	{
		//set scroll speed
		scrollPane.getVerticalScrollBar().setUnitIncrement(20);
		scrollPane.getHorizontalScrollBar().setUnitIncrement(20);
		
		//earthquakes panel
		earthquakes.add(buttonsPanel, "span");
		earthquakes.add(randomQuakesLabel);
		buttonsPanel.add(addButt);
		addButt.addActionListener(new ActionListener()
		{
			public void actionPerformed(ActionEvent e)
			{
				addQuake();
			}
		});
		buttonsPanel.add(removeButt);
		removeButt.addActionListener(new ActionListener()
		{
			public void actionPerformed(ActionEvent e)
			{
				removeQuake();
			}
		});
	}

	protected static void addQuake()
	{
		earthquakes.remove(randomQuakesLabel);
		
		final Quake quake = new Quake();
		quakeList.add(quake);
		
		//get the index of this particular arraylist member
		final int index = (quakeList.indexOf(quake));

		quakeList.get(index).quakePanel.add(new JLabel("Start month:"));
		quakeList.get(index).quakePanel.add(quakeList.get(index).startMonthTF);
		quakeList.get(index).startMonthTF.addFocusListener(new FocusListener()
		{
			public void focusGained(FocusEvent e)
			{
				JTextField tf = (JTextField) e.getComponent();
				tf.selectAll();
				Gui.tempValue = tf.getText();
			}
			public void focusLost(FocusEvent e)
			{
				try
				{
					int input = Integer.parseInt(((JTextField) e.getComponent()).getText());
					if (input < 1)
					{
						quakeList.get(index).startMonth = Integer.parseInt(Gui.tempValue);
						quakeList.get(index).startMonthTF.setText(Gui.tempValue);
					}
					else
						quakeList.get(index).startMonth = input;
				}catch(NumberFormatException nfe)
				{
					quakeList.get(index).startMonth = Integer.parseInt(Gui.tempValue);
					quakeList.get(index).startMonthTF.setText(Gui.tempValue);
				}
				//if start month is bigger than endmonth, make them equal.
				if (quakeList.get(index).startMonth > quakeList.get(index).endMonth)
				{
					quakeList.get(index).endMonth = quakeList.get(index).startMonth;
					quakeList.get(index).endMonthTF.setText(quakeList.get(index).startMonthTF.getText());
				}
			}
		});
		quakeList.get(index).quakePanel.add(new JLabel("End month:"));
		quakeList.get(index).quakePanel.add(quakeList.get(index).endMonthTF);
		quakeList.get(index).endMonthTF.addFocusListener(new FocusListener()
		{
			public void focusGained(FocusEvent e)
			{
				JTextField tf = (JTextField) e.getComponent();
				tf.selectAll();
				Gui.tempValue = tf.getText();
			}
			public void focusLost(FocusEvent e)
			{
				try
				{
					int input = Integer.parseInt(((JTextField) e.getComponent()).getText());
					if (input < 1)
					{
						quakeList.get(index).endMonth = Integer.parseInt(Gui.tempValue);
						quakeList.get(index).endMonthTF.setText(Gui.tempValue);
					}
					else
						quakeList.get(index).endMonth = input;
				}catch(NumberFormatException nfe)
				{
					quakeList.get(index).endMonth = Integer.parseInt(Gui.tempValue);
					quakeList.get(index).endMonthTF.setText(Gui.tempValue);
					
				}
				//if start month is bigger than endmonth, make them equal.
				if (quakeList.get(index).startMonth > quakeList.get(index).endMonth)
				{
					quakeList.get(index).endMonth = quakeList.get(index).startMonth;
					quakeList.get(index).endMonthTF.setText(quakeList.get(index).startMonthTF.getText());
				}
			}
		});
		quakeList.get(index).quakePanel.add(new JLabel("Severity:"));
		quakeList.get(index).quakePanel.add(quakeList.get(index).severityTF);
		quakeList.get(index).severityTF.addFocusListener(new FocusListener()
		{
			public void focusGained(FocusEvent e)
			{
				JTextField tf = (JTextField) e.getComponent();
				tf.selectAll();
				Gui.tempValue = tf.getText();
			}
			public void focusLost(FocusEvent e)
			{
				try
				{
					int input = Integer.parseInt(((JTextField) e.getComponent()).getText());
					if (input < 1)
					{
						quakeList.get(index).severity = 1;
						quakeList.get(index).severityTF.setText(Integer.toString(quakeList.get(index).severity));
					}
					else if (input > 99)
					{
						quakeList.get(index).severity = 99;
						quakeList.get(index).severityTF.setText(Integer.toString(quakeList.get(index).severity));
					}
					else
						quakeList.get(index).severity = input;
				}catch(NumberFormatException nfe)
				{
					quakeList.get(index).severity = Integer.parseInt(Gui.tempValue);
					quakeList.get(index).severityTF.setText(Gui.tempValue);
				}
			}
		});
		
		earthquakes.add(quakeList.get(index).quakePanel, "span");
		earthquakes.updateUI();
		
		//increment startMonth, endMonth with each add
		if (quakeList.size() > 1)
		{
			quakeList.get(index).startMonth = quakeList.get(index -1).endMonth +6;
			int endMonthPlus = Integer.parseInt(quakeList.get(index -1).endMonthTF.getText()) +6;
			quakeList.get(index).startMonthTF.setText(Integer.toString(endMonthPlus));
			
			quakeList.get(index).endMonth = quakeList.get(index).startMonth +12;
			int startMonthPlus = Integer.parseInt(quakeList.get(index).startMonthTF.getText()) +12;
			quakeList.get(index).endMonthTF.setText(Integer.toString(startMonthPlus));
		}
		
	}

	protected static void removeQuake()
	{
		int lastIndex = quakeList.size()-1;
		if (lastIndex >= 0)
		{
			//remove panel
			earthquakes.remove(quakeList.get(lastIndex).quakePanel);
			earthquakes.updateUI();
			//remove object from the arraylist
			quakeList.remove(lastIndex);
			if (quakeList.size() == 0)
				earthquakes.add(randomQuakesLabel);
		}
		
	}
}
