package org.example;

import javax.swing.*;
import java.awt.*;

public class MyGUI extends JFrame {

    private final int WIDTH = 600;
    private final int HEIGHT = 600;

    public MyGUI(String title) {
        super(title);
        setSize(WIDTH, HEIGHT);
        add(new Board());
        setVisible(true);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    }

}