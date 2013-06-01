using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
//Include mysql client namespace.
using MySql.Data.MySqlClient;
using System.Configuration;
using System.IO;

namespace CSharpMySqlSample
{
    public partial class frmMySqlSample : Form
    {
        //Read connection string from application settings file
        private string ConnectionString = "";//"ConfigurationSettings.AppSettings["ConnectionString"];
        MySqlConnection connection;
        MySqlDataAdapter adapter;
        DataTable DTItems1;
   
        private string  l1 = ""; 

        public frmMySqlSample()
        {
            try
            {
                InitializeComponent(); 
            }
            catch
            {
            }
            
        }

        private void frmMySqlSample_Load(object sender, EventArgs e)
        {
            try
            {
                
          
            ConnectionString = ConfigurationSettings.AppSettings["ConnectionString"];
            
                  }
            catch(Exception)
            {
                
            }
            for (Int32 i = 1970; i <= Convert.ToInt32(DateTime.Now.Year); i++ )
            {

                cmby1.Items.Add(i);
                cmby2.Items.Add(i);
            }
            cmbday1.SelectedIndex = 0;
            cmbm1.SelectedIndex = 0;
            cmby1.SelectedIndex = 0;
        }


        private void cmdConnect_Click(object sender, EventArgs e)
        {
            //Initialize mysql connection
            ConnectionString = "SERVER=" + txtServer.Text + ";DATABASE=" + txtDB.Text + ";UID=" + txtUser.Text + ";PASSWORD=" + txtPass.Text + ";";
            connection = new MySqlConnection(ConnectionString);
            connection.Open();


        }
        DataTable GetAllItems(String sql)
        {
            try
            {
                 
                //prepare query to get all records from items table
                string query =sql ;
                //prepare adapter to run query
                adapter = new MySqlDataAdapter(query, connection);
                DataSet DS = new DataSet();
                //get query results in dataset
 
                adapter.Fill(DS);

                return DS.Tables[0];
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            return null;
        }



        private void button1_Click(object sender, EventArgs e)
        {
            String data1 = "";
            String data2 = "";
            try
            {
                 data1 = cmby1.SelectedItem.ToString() + "-" + cmbm1.SelectedItem.ToString() + "-" + cmbday1.SelectedItem.ToString();
                 data2 = cmby2.SelectedItem.ToString() + "-" + cmbm2.SelectedItem.ToString() + "-" + cmbd2.SelectedItem.ToString();

            }
            catch (Exception)
            {
                
              
            }
            l1 = string.Format(@"SELECT ALLRES.date,sum(nofUsers) as nofUsers,sum(nofQuestions) as nofQuestions,sum(nofAnswers) as nofAnswers,sum(nofOfAnswersRank)as nofOfAnswersRank FROM  " + " ( SELECT * FROM ( " + " (SELECT DATE_FORMAT(userCounter.date,'%Y-%m-%d')as date  , sum(userCounter.c) as nofUsers, 0 as nofQuestions , 0 as nofAnswers, 0 as nofOfAnswersRank FROM  " + " ((SELECT  count(*) as c,DATE_FORMAT(RE.id_date,'%Y-%m-%d') as date FROM tbl_remark AS RE WHERE RE.id_date >= '{1}' AND RE.id_date <= '{0}' GROUP BY RE.id_date)  " + " UNION (SELECT  count(*) as c,DATE_FORMAT(QR.id_date,'%Y-%m-%d') as date FROM tbl_question_rank AS QR WHERE QR.id_date >= '{1}' AND QR.id_date <= '{0}' GROUP BY QR.id_date)  " + " UNION (SELECT  count(*) as c,DATE_FORMAT(Q.id_date,'%Y-%m-%d') as date FROM tbl_question AS Q WHERE Q.id_date >= '{1}' AND Q.id_date <= '{0}' GROUP BY Q.id_date)  " + " UNION (SELECT count(*) as c,DATE_FORMAT(A.id_date,'%Y-%m-%d') as date FROM tbl_answer AS A WHERE A.id_date >= '{1}' AND A.id_date <= '{0}' GROUP BY A.id_date)  " + " UNION (SELECT count(*) as c,DATE_FORMAT(A.id_date,'%Y-%m-%d') as date FROM tbl_answer AS A WHERE A.id_date_rank >= '{1}' AND A.id_date_rank <= '{0}' GROUP BY A.id_date ) ) " + "  as userCounter " + " GROUP BY DATE(userCounter.date) ORder by userCounter.date) as t1 ) " + " UNION ((SELECT DATE_FORMAT(Q.id_date,'%Y-%m-%d') as date,0 as nofUsers, count(*) as nofQuestions, 0 as nofAnswers, 0 as nofOfAnswersRank FROM tbl_question AS Q WHERE Q.id_date >= '{1}' AND Q.id_date <= '{0}' GROUP BY Q.id_date )) " + " UNION ((SELECT DATE_FORMAT(A.id_date,'%Y-%m-%d')as date ,0 as nofUsers,0 as nofQuestions,count(*) as nofAnswers , 0 as nofOfAnswersRank FROM tbl_answer AS A WHERE A.id_date >= '{1}' AND A.id_date <= '{0}' GROUP BY A.id_date))   " + " UNION ((SELECT DATE_FORMAT(A.id_date,'%Y-%m-%d')as date ,0 as nofUsers,0 as nofQuestions,0 as nofAnswers , count(*) as nofOfAnswersRank FROM tbl_answer AS A WHERE A.id_date_rank >= '{1}' AND A.id_date_rank <= '{0}' GROUP BY A.id_date_rank )) " + " ) as ALLRES GROUP BY ALLRES.date ORDER BY ALLRES.date", data2,data1);
            //Get all items in datatable
            DTItems1 = GetAllItems(l1);
       
            //Fill grid with items
            dataGridView1.DataSource = DTItems1;

            //  dataGridView2.DataSource = DTItems2;
            String Filepath = Path.GetDirectoryName(System.Windows.Forms.Application.ExecutablePath).ToString() + "\\result.csv";
            TextWriter tw = new StreamWriter(Filepath);
            tw.WriteLine("Date;nofUsers;nofQuestions;nofAnswers;nofOfBestAnswersRating");

          //  for (int i = 0; i <= DTItems1.Rows.Count; i++)
                foreach (DataRow r in DTItems1.Rows)
                {
                    tw.WriteLine(r[0].ToString() + ";" +
                      r[1].ToString() + ";" +
                      r[2].ToString() + ";" +
                      r[3].ToString() + ";" +
                      r[4].ToString());                  
                }
           // {
            //    tw.WriteLine(DTItems1.Columns[0].ToString() + ";" +
            //        DTItems1.Rows.Count  .ToString() + ";" +
            //        DTItems1.Columns[2].ToString() + ";" +
           //         DTItems1.Columns[3].ToString() + ";" +
           //         DTItems1.Columns[4].ToString());
           // }
            tw.Close();
            MessageBox.Show("See Folder of Application Path\r\n The file is called result.csv \r\n Here: " + Filepath);
        }

        private void comboBox2_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void comboBox3_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }


        private void timer1_Tick(object sender, EventArgs e)
        {
            try
            {
                //MessageBox.Show(connection.State.ToString());
                if(connection.State.ToString() != "Open")
                {
                    button1.Enabled = false;

                }
                else
                {
                    try
                    {
                        cmdDisconnect.Enabled = true;
                        cmdConnect.Enabled = false;
                        String data1 = cmby1.SelectedItem.ToString() + "-" + cmbm1.SelectedItem.ToString() + "-" + cmbday1.SelectedItem.ToString();
                        String data2 = cmby2.SelectedItem.ToString() + "-" + cmbm2.SelectedItem.ToString() + "-" + cmbd2.SelectedItem.ToString();
                          
                        button1.Enabled = true;
                    }
                    catch (Exception)
                    {
                        
                   
                    }

                }
            }
            catch (Exception)
            {

                button1.Enabled = false;
            }
            
        }

        private void cmdDisconnect_Click(object sender, EventArgs e)
        {
            connection.Close();
            cmdDisconnect.Enabled = false;
            cmdConnect.Enabled = true;
        }

    }
}