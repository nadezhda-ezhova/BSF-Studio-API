const express    = require('express');
const reqId      = require('express-request-id')();
const shell      = require('shelljs');
const multer     = require('multer');
const bodyParser = require('body-parser');
const cors       = require('cors');


const workDir  = (req) => `/tmp/uploads/${req.id}`;
const app_home = '/var/www';
var allowedOrigins = ['http://localhost:8080'];


const server  = express();
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    shell.exec(`mkdir -p ${workDir(req)}`);
    cb(null, workDir(req));
  },
  filename: (req, file, cb) => cb(null, file.originalname)
});
const upload = multer({ storage });


server.use(cors({
  origin: (origin, callback) => {
    if (!origin) return callback(null, true);

    if (allowedOrigins.indexOf(origin) === -1) {
      var msg = `The CORS policy for site '${origin}' does not exist`;
      return callback(new Error(msg), false);
    }
  }
}));
server.use(reqId);
server.use(bodyParser.json());
server.use(bodyParser.urlencoded());
server.use(bodyParser.urlencoded({ extended: true }));
const listener = server.listen(process.env.NODE_PORT || 3000, '0.0.0.0', () => {
  console.log('App %s listening at %s', server.name, listener.address().port);
});

const cleanup = (req) => shell.exec(`rm -rf ${workDir(req)}`);

server.post('/compile', upload.array('src'), (req, res) => {
  console.log(req.originalUrl);
  const sampleDir = `${app_home}/samples/BSF-MR`;

  // Copy BSF Implementation
  shell.exec(`cp ${sampleDir}/BSF-* ${workDir(req)}`);

  // Compile BSF
  shell.exec(
    `cd ${workDir(req)} && mpic++ *.cpp -o ./app`,
    (code, stdout, stderr) => {
      res.send({ code, stdout, stderr });
      cleanup(req);
    }
  );
});


server.post('/run', upload.array('src'), (req, res) => {
  console.log(req.originalUrl);
  const sampleDir = `${app_home}/samples/BSF-MR`;
  const procPerNode = req.body.procPerNode || 2;
  const runPerNode  = req.body.runPerNode || 2;

  // Copy BSF Implementation
  shell.exec(`cp ${sampleDir}/BSF-* ${workDir(req)}`);

  const result = {};

  const cleanup = () => shell.exec(`rm -rf ${workDir(req)}`);

  // Compile BSF
  shell.exec(
    `cd ${workDir(req)} && mpic++ *.cpp -o ./app`,
    (code, stdout, stderr) => {
      result.compile = { code, stdout, stderr };

      if (code != '0') {
        res.send(result);
        cleanup(req);
      } else {
        shell.exec(
          `cd ${workDir(req)} && mpirun -verbose -np ${runPerNode} ./app`,
          (code, stdout, stderr) => {
            result.run = { code, stdout, stderr };
            res.send(result);
            cleanup(req);
          }
        );
      }
    }
  );
});