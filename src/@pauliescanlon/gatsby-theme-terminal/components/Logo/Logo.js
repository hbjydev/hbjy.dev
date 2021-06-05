/** @jsx jsx */
import { jsx } from "theme-ui";
import { Link } from "gatsby";

export const Logo = () => (
  <Link style={{ color: 'white', textDecoration: 'none' }} to="/">
    <div sx={{ height: "25px", overflow: "hidden" }}>
      Hayden's Dumping Ground
    </div>
  </Link>
);
