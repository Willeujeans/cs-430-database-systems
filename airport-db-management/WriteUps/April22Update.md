## Project - Updated Instructions

# Project Instructions

To run the applications, you have two options: either run them remotely using the CS department’s Linux machines or locally on your machine. **Locally** refers to running on your personal device, as opposed to running on a CS machine, regardless of whether you’re connected to the CSU network.

## 1. Running Remotely

You’ll need remote access to the Linux machines in the CS department. If you haven’t accessed them before, refer to the following guides:

- [https://sna.cs.colostate.edu/remote-connection/vpnLinks to an external site.](https://sna.cs.colostate.edu/remote-connection/vpn "(opens in a new window)")
    
- [https://sna.cs.colostate.edu/remote-connection/sshLinks to an external site.](https://sna.cs.colostate.edu/remote-connection/ssh "(opens in a new window)")
    
- [https://sna.cs.colostate.edu/remote-connection/guiLinks to an external site.](https://sna.cs.colostate.edu/remote-connection/gui "(opens in a new window)")
    

You should also be familiar with Linux modules. If not, read the following guides. They’ll help not only with this class but throughout your studies:

- [https://sna.cs.colostate.edu/software/environment-modulesLinks to an external site.](https://sna.cs.colostate.edu/software/environment-modules "(opens in a new window)")
    
- [https://sna.cs.colostate.edu/software/python-librariesLinks to an external site.](https://sna.cs.colostate.edu/software/python-libraries "(opens in a new window)")
    
- [https://sna.cs.colostate.edu/software/javaLinks to an external site.](https://sna.cs.colostate.edu/software/java "(opens in a new window)")
    

For general information about computing resources in the department, visit:

- [https://sna.cs.colostate.edu/Links to an external site.](https://sna.cs.colostate.edu/ "(opens in a new window)")
    

### 1.1. Preparing the environment

Once you have SSH access and have copied the project files to the remote machine, load the required modules:

```bash
module purge
module load python/bundle-3.8
module load java/20
```

Then, navigate to the project directory and set up the Python virtual environment:

```bash
virtualenv .
source bin/activate
pip install pyodbc Flask
```

### 1.2. Running the Flask app

To start the Flask app:

```bash
python manager_app.py
```

The application will launch on port `5000`, which is not accessible from outside the CS network. To access it **locally from your machine**, you can tunnel the remote port `5000` to your local port `5000`. To do so, run the following command on **your local machine**:

```bash
ssh -N -L 5000:localhost:5000 username@machine.cs.colostate.edu
```

Where **username** is your CSUID, and **machine** is the hostname of the CS Linux machine running the Flask app. When prompted, enter the password used for SSH access. Once the tunnel is active, open your browser and go to:

- [http://127.0.0.1:5000Links to an external site.](http://127.0.0.1:5000/ "(opens in a new window)")
    

When finished, deactivate the Python virtual environment:

```bash
deactivate
```

### 1.3. Running the Java app

To run the Java application remotely, open a remote desktop session and execute the following command in a terminal:

```bash
export _JAVA_OPTIONS='-Dsun.java2d.xrender=false'
java -cp .:postgresql-42.7.5.jar AirplaneTestApp.java
```

## 2. Running Locally

These instructions are intended for Linux systems. If you’re using macOS, the process is very similar and should require only minor adjustments. If you’re on Windows, we recommend using the Windows Subsystem for Linux (WSL):

- [https://learn.microsoft.com/en-us/windows/wsl/installLinks to an external site.](https://learn.microsoft.com/en-us/windows/wsl/install "(opens in a new window)")
    

You need to install virtualenv, the ODBC driver manager, and the PostgreSQL ODBC driver required by `pyodbc`. For Debian-based distributions, such as WSL, this requires the installation of the following packages:

```bash
sudo apt update
sudo apt install unixodbc
sudo apt install odbc-postgresql
sudo apt install virtualenv
```

Then, navigate into the project directory, create a Python virtual environment, and install the dependencies:

```bash
virtualenv .
source bin/activate
pip install pyodbc Flask
```

To run the Flask app:

```bash
python manager_app.py
```

You should be able to access the Flask application from your local browser at:

- [http://127.0.0.1:5000Links to an external site.](http://127.0.0.1:5000/ "(opens in a new window)")
    

Make sure Java is installed. The project already includes the PostgreSQL JDBC driver. To compile and run the Java app, use one of the following commands (depending on your Java version):

```bash
java -cp .:postgresql-42.7.5.jar AirplaneTestApp.java
```

```bash
java -cp .:postgresql-42.7.5.jar AirplaneTestApp
```

In order for the applications to access the PostgreSQL database on `faure.cs.colostate.edu`, you can tunnel the remote port `5432` to your local port. Run the following command **on your local machine**:

```bash
ssh -N -L 5432:localhost:5432 username@faure.cs.colostate.edu
```

Where **username** is your CSUID. When prompted, enter the password used for SSH access. This forwards the remote PostgreSQL port to your local machine so that both applications can connect as if the database were running on `localhost:5432`.

## 3. DSN

As discussed in class, you’ll need to define a DSN (Data Source Name) for the ODBC connection using `pyodbc`. The format is:

```
DSN = "DRIVER=;SERVER=;PORT=;DATABASE=;UID=;PWD="
```

- Use `SERVER=faure.cs.colostate.edu` when running the Flask app on a CS machine.
    
- Use `SERVER=localhost` if running the app locally and forwarding the PostgreSQL port as shown above.
    
- `PORT=5432`
    
- `UID=your CSU NetID`
    
- `PWD=your CSU ID` (unless you’ve changed it)
    

The driver depends on your operating system. On a CS Linux machine, list available drivers with:

```bash
odbcinst -q -d
```

All CS Linux machines come with the ODBC driver manager and the PostgreSQL ODBC driver.

For the Java application, the JDBC URL has the following format:

```java
private static final String DB_URL = "jdbc:postgresql://server:5432/yourdbname?currentSchema=airport";
```

Replace `server` with either `faure.cs.colostate.edu` or `localhost`, depending on where the Java app is running.

## 4. /airplanes/delete

The `/airplanes/delete` endpoint needs to be fixed. Implement the helper function `get_models()` and update the return line as follows:

```python
return render_template('airplanes.html', airplanes=get_airplanes(), models=get_models(), action="Delete")
```

## 5. A word about SSH tunnels

If you’re running the applications on a CS Linux machine, you do **not** need to tunnel the PostgreSQL port — you can connect directly to `faure.cs.colostate.edu`. However, you **do** need to tunnel port `5000` if you want to access the Flask app from your local browser.

If you’re running the applications **locally**, you do **not** need to tunnel the Flask port — it’s already available on `localhost`. But you **do** need to tunnel port `5432` from `faure.cs.colostate.edu` so that your apps can connect to PostgreSQL as if it were running locally.

Last updated 2025-04-24 13:35:25 -0600
