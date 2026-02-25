package org.example;

import javax.swing.JPanel;
import java.awt.*;

public class Board extends JPanel {

    private final int X1 = 100;
    private final int Y1 = 100;
    private final int RAGGIO1 = 30;

    private final int X2 = 300;
    private final int Y2 = 300;
    private final int RAGGIO2 = 30;

    private final int X3 = 150;
    private final int Y3 = 150;
    private final int RAGGIO3 = 30;

    private final int DELAY = 25;
    private final int VEL = 2;

    private int x1, y1;
    private int x2, y2;
    private int x3, y3;

    private int vel_x1, vel_y1;
    private int vel_x2, vel_y2;
    private int vel_x3, vel_y3;

    private Thread Circle1;
    private Thread Circle2;
    private Thread Circle3;
    public Board() {
        setBackground(Color.black);
        x1 = X1;
        y1 = Y1;

        x2 = X2;
        y2 = Y2;

        x3 = X3;
        y3 = Y3;

        vel_x1 = VEL;
        vel_y1 = VEL;

        vel_x2 = VEL;
        vel_y2 = VEL;

        vel_x3 = VEL;
        vel_y3 = VEL;

        Circle1 = new Thread(() -> task());
        Circle2 = new Thread(() -> task());
        Circle3 = new Thread(() -> task());

        Circle1.start();
        Circle2.start();
        Circle3.start();

    }

    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        Graphics2D g2d = (Graphics2D) g;
        g2d.setStroke(new BasicStroke(4));
        g2d.setColor(Color.white);
        g2d.fillOval(x1, y1, RAGGIO1*2, RAGGIO1*2);
        g2d.setColor(Color.white);
        g2d.fillOval(x2, y2, RAGGIO2*2, RAGGIO2*2);
        g2d.setColor(Color.white);
        g2d.fillOval(x3, y3, RAGGIO3*2, RAGGIO3*2);
        Toolkit.getDefaultToolkit().sync();
    }

    private void loop() {
        x1 += vel_x1;
        y1 += vel_y1;

        x2 += vel_x2;
        y2 += vel_y2;

        x3 += vel_x3;
        y3 += vel_y3;

        int a1 = x1 + RAGGIO1;
        int b1 = y1 + RAGGIO1;

        int a2 = x2 + RAGGIO2;
        int b2 = y2 + RAGGIO2;

        int a3 = x3 + RAGGIO3;
        int b3 = y3 + RAGGIO3;

        if((a1-a2)*(a1-a2) + (b1-b2)*(b1-b2) < (RAGGIO1+RAGGIO2)*(RAGGIO1+RAGGIO2)){
            vel_x1 = -vel_x1;
            vel_y1 = -vel_y1;
            vel_x2 = -vel_x2;
            vel_y2 = -vel_y2;
        }

        if((a1-a3)*(a1-a3) + (b1-b3)*(b1-b3) < (RAGGIO1+RAGGIO3)*(RAGGIO1+RAGGIO3)){
            vel_x1 = -vel_x1;
            vel_y1 = -vel_y1;
            vel_x3 = -vel_x3;
            vel_y3 = -vel_y3;
        }

        if((a2-a3)*(a2-a3) + (b2-b3)*(b2-b3) < (RAGGIO2+RAGGIO3)*(RAGGIO2+RAGGIO3)){
            vel_x2 = -vel_x2;
            vel_y2 = -vel_y2;
            vel_x3 = -vel_x3;
            vel_y3 = -vel_y3;
        }

        if (x1 + RAGGIO1*2 > getWidth() || x1 < 0) {
            vel_x1 = -vel_x1;
        }
        if (y1 + RAGGIO1*2 > getHeight() || y1 < 0) {
            vel_y1 = -vel_y1;
        }

        if (x2 + RAGGIO2*2 > getWidth() || x2 < 0) {
            vel_x2 = -vel_x2;
        }
        if (y2 + RAGGIO2*2 > getHeight() || y2 < 0) {
            vel_y2 = -vel_y2;
        }

        if (x3 + RAGGIO3*2 > getWidth() || x3 < 0) {
            vel_x3 = -vel_x3;
        }
        if (y3 + RAGGIO1*3 > getHeight() || y3 < 0) {
            vel_y3 = -vel_y3;
        }
    }

    public void task() {
        while (true) {
            loop();
            repaint();
            try {
                Thread.sleep(DELAY);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

}