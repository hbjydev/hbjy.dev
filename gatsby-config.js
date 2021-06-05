module.exports = {
  siteMetadata: {
    name: "Hayden's Dumping Ground",
    description: "Hayden's mental dumping ground online. It's not that interesting, really.",
    keywords: ["tech", "blog", "sysadmin", "devops", "developer", "maybe not human?"],
    siteUrl: "https://hbjy.dev",
    siteImage: "terminal-open-graph-image.jpg",
    profileImage: `https://github.com/hbjydev.png`,
    lang: `en`,
    config: {
      sidebarWidth: 280
    }
  },
  plugins: [
    {
      resolve: "@pauliescanlon/gatsby-theme-terminal",
      options: {
        source: ["posts"]
      }
    }
  ]
};
