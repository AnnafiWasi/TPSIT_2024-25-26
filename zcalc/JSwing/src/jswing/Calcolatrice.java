/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package jswing;
import com.formdev.flatlaf.FlatLightLaf;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;
/**
 *
 * @author PC
 */
public class Calcolatrice {
    public static void main(String[] args) {
        try {
            UIManager.setLookAndFeel(new FlatLightLaf());
            System.out.println("FlatLaf applicato");
        } catch (UnsupportedLookAndFeelException ex) {
            ex.printStackTrace();
        }
        javax.swing.SwingUtilities.invokeLater(() -> new AspettoCalcolatrice().creaGUI());
    }
}
