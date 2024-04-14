import express from "express";
import { myConfig } from "./config.js";
import { sum } from "./utils.js";

const app = express();
const port = 3000;

const myArray = [1, 2, 3, 4];

app.get("/", (req, res) => {
  console.log(myConfig);
  const result = sum(12, 29);
  res.send("Hello World!");
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
