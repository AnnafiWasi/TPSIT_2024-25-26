/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package jswing;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

/**
 *
 * @author PC
 */

public class AspettoCalcolatrice extends JFrame{
    private JTextField textField;
    private Stato stato;

    public AspettoCalcolatrice() {
        stato = new Stato();
    }

    public void creaGUI() {
        setTitle("Calcolatrice");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setSize(350, 450);
        setLayout(new BorderLayout());
        setResizable(false);
        Image icon = new ImageIcon(this.getClass().getResource("/Wasi.jpg")).getImage();
        setIconImage(icon);
        textField = new JTextField();
        textField.setFont(new Font("Monospaced", Font.PLAIN, 30));
        textField.setHorizontalAlignment(JTextField.RIGHT);
        textField.setBackground(Color.white);
        textField.setForeground(Color.black);
        textField.setEditable(false);
        add(textField, BorderLayout.NORTH);
        JPanel pannelloBottoni = new JPanel();
        pannelloBottoni.setLayout(new GridLayout(5, 4, 7, 5));
        String[] bottoni = {
            "C","n^x", "x√n", "%",
            "7", "8", "9", "/",
            "4", "5", "6", "*",
            "1", "2", "3", "-",
            ".", "0", "=", "+"
        };
        for (int i = 0; i < bottoni.length; i++) {
            JButton bottone = new JButton(bottoni[i]);
            bottone.setFont(new Font("Serif", Font.PLAIN, 18));
            bottone.setBackground(Color.white);
            bottone.setForeground(Color.black);
            bottone.setFocusable(false);
            pannelloBottoni.add(bottone);
            bottone.addActionListener(new BottoneListener());
        }
        add(pannelloBottoni, BorderLayout.CENTER);
        setVisible(true);
    }

    private class BottoneListener implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent e) {
            String input = ((JButton) e.getSource()).getText();
            String risultato = stato.gestisciInput(input, textField.getText());
            textField.setText(risultato);
        }
    }
}
